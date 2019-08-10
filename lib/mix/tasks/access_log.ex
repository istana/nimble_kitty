defmodule Mix.Tasks.Import.AccessLogs do
  use Mix.Task
  import Ecto.Query, warn: false
  alias NimbleKitty.HttpRequest
  alias NimbleKitty.Repo

  def run(args) do
    Mix.Task.run("app.start")
    Mix.shell.info("Greetings from the Hello Phoenix Application!")
    Mix.shell().info(Enum.join(args, " "))

    if length(args) === 0 do
      Mix.shell.error("usage: mix Import.AccessLogs file/directory [file/directory] ...")
    else
      Enum.map(args, &process_path/1)
    end
  end

  def process_path(path) do
    File.stream!(path, [:utf8, :read])
      |> Stream.map(fn line ->
        Regex.named_captures(~r/(?<host>.+?) (?<ident>.+?) (?<username>.+?) \[(?<datetime>.+?)\] "(?<request>.+?)" (?<statuscode>.+?) (?<bytes>.+?) "(?<referrer>.+?)" "(?<useragent>.+?)"/, line)
      end)
      |> Enum.map(&insert_record/1)
  end

  defp insert_record(combined) do
    time = Timex.parse!(combined["datetime"], "%d/%b/%Y:%H:%M:%S %z", :strftime)
    request = Regex.named_captures(~r/(?<verb>.+?) (?<path>.+?) (?<version>.+?)\z/, combined["request"])
    attrs = %{
      ip_address: combined["host"],
      time: time,
      verb: request["verb"] || "-",
      url: request["path"] || "-",
      version: request["version"] || "-",
      status: combined["statuscode"],
      response_size: (if combined["bytes"] == "-", do: -1, else: combined["bytes"]),
      user_agent: combined["useragent"],
      referrer: combined["referrer"] || "-"
    }

    changeset = %HttpRequest{}
      |> HttpRequest.changeset(attrs)
    IO.inspect(attrs)
    IO.inspect(changeset)
    dedup_query = from r in HttpRequest,
      where:
        r.ip_address == ^changeset.changes.ip_address
          and r.time == ^changeset.changes.time
          and r.verb == ^changeset.changes.verb
          and r.url == ^changeset.changes.url
          and r.version == ^changeset.changes.version
          and r.status == ^changeset.changes.status
          and r.response_size == ^changeset.changes.response_size
          and r.user_agent == ^changeset.changes.user_agent
          and r.referrer == ^changeset.changes.referrer,
      limit: 1
    already_exists? = Repo.all(dedup_query)

    if !already_exists? do
      changeset
        |> Repo.insert()
        |> IO.inspect()
    else
      IO.inspect("already inserted")
    end
  end
end

defmodule Mix.Tasks.Import.AccessLogs do
  use Mix.Task
  import Ecto.Query
  alias NimbleKitty.HttpRequest
  alias NimbleKitty.Repo

  def run(args) do
    Mix.Task.run("app.start")
    Mix.shell().info(Enum.join(args, " "))

    if length(args) === 0 do
      Mix.shell().error("usage: mix Import.AccessLogs file/directory [file/directory] ...")
    else
      Enum.map(args, &process_path/1)
    end
  end

  def process_path(path) do
    File.stream!(path, [:utf8, :read])
    |> Stream.map(fn line ->
      Regex.named_captures(
        ~r/\A(?<host>.+?) (?<ident>.+?) (?<username>.+?) \[(?<datetime>.+?)\] "(?<request>.+?)" (?<statuscode>.+?) (?<bytes>.+?) "(?<referrer>.+?)" "(?<useragent>.+?)"/,
        line
      )
    end)
    |> Enum.map(&insert_record/1)
  end

  defp insert_record(combined) do
    time = Timex.parse!(combined["datetime"], "%d/%b/%Y:%H:%M:%S %z", :strftime)

    request =
      Regex.named_captures(~r/(?<verb>.+?) (?<path>.+?) (?<version>.+?)\z/, combined["request"])

    attrs = %{
      ip_address: combined["host"],
      time: time,
      verb: request["verb"],
      url: request["path"],
      version: request["version"],
      status: combined["statuscode"],
      response_size: if(combined["bytes"] == "-", do: -1, else: combined["bytes"]),
      user_agent: if(combined["useragent"] == "-", do: nil, else: combined["useragent"]),
      referrer: if(combined["referrer"] == "-", do: nil, else: combined["referrer"])
    }

    changeset =
      %HttpRequest{}
      |> HttpRequest.changeset(attrs)

    IO.inspect(attrs)
    IO.inspect(changeset)

    dedup_query =
      from r in HttpRequest,
        where:
          r.ip_address == ^Map.get(changeset.changes, :ip_address) and
            r.time == ^Map.get(changeset.changes, :time) and
            r.verb == ^Map.get(changeset.changes, :verb) and
            r.url == ^Map.get(changeset.changes, :url) and
            r.version == ^Map.get(changeset.changes, :version) and
            r.status == ^Map.get(changeset.changes, :status) and
            r.response_size == ^Map.get(changeset.changes, :response_size) and
            r.user_agent == ^Map.get(changeset.changes, :user_agent) and
            r.referrer == ^Map.get(changeset.changes, :referrer),
        limit: 1

    already_exists? = Repo.one(dedup_query)
    IO.inspect(already_exists?)

    if !already_exists? do
      changeset
      |> Repo.insert()
      |> IO.inspect()
    else
      IO.inspect("already inserted")
    end
  end
end

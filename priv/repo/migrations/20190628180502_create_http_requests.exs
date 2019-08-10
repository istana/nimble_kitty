defmodule NimbleKitty.Repo.Migrations.CreateHttpRequests do
  use Ecto.Migration

  def change do
    create table(:http_requests) do
      add :ip_address, :text
      add :time, :utc_datetime_usec
      add :verb, :text
      add :url, :text
      add :version, :text
      add :status, :integer
      add :response_size, :integer
      add :user_agent, :text
      add :referrer, :text

      timestamps()
    end
  end
end

defmodule NimbleKitty.Repo.Migrations.CreateHttpRequests do
  use Ecto.Migration

  def change do
    create table(:http_requests) do
      add :ip_address, :string
      add :time, :utc_datetime_usec
      add :verb, :string
      add :url, :string
      add :version, :string
      add :status, :integer
      add :response_size, :integer
      add :user_agent, :string
      add :referrer, :string

      timestamps()
    end

  end
end

defmodule NimbleKitty.HttpRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "http_requests" do
    field :ip_address, :string
    field :response_size, :integer
    field :status, :integer
    field :time, :utc_datetime_usec
    field :url, :string
    field :user_agent, :string
    field :verb, :string
    field :version, :string
    field :referrer, :string

    timestamps()
  end

  @doc false
  def changeset(http_request, attrs) do
    http_request
    |> cast(attrs, [:ip_address, :time, :verb, :url, :version, :status, :response_size, :user_agent, :referrer])
    |> validate_required([:ip_address, :time, :status])
  end
end

defmodule NimbleKittyWeb.PageController do
  use NimbleKittyWeb, :controller
  import Ecto.Query
  alias NimbleKitty.HttpRequest
  alias NimbleKitty.Repo

  def index(conn, _params) do
    total_requests = elem(Repo.one(from r in HttpRequest, select: {count("*")}), 0)
    render(conn, "index.html", total_requests: total_requests)
  end
end

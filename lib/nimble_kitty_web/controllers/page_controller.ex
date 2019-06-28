defmodule NimbleKittyWeb.PageController do
  use NimbleKittyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

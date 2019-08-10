defmodule NimbleKittyWeb.PageController do
  use NimbleKittyWeb, :controller
  use Timex
  import Ecto.Query
  alias NimbleKitty.HttpRequest
  alias NimbleKitty.Repo

  def index(conn, _params) do
    accesses_query = from r in HttpRequest,
      select: count(r.id),
      where: not(like(r.url, "%.ttf%"))
        and not(like(r.url, "%.css%"))
        and not(like(r.url, "%.js%"))
        and not(like(r.url, "%.jpg%"))
        and not(like(r.url, "%.jpeg%"))
        and not(like(r.url, "%.png%"))
        and not(like(r.url, "%.svg%"))
    last24h_query = from r in accesses_query,
      where: r.time > ^Timex.shift(Timex.now, hours: -24)
    last48h_query = from r in accesses_query,
      where: r.time > ^Timex.shift(Timex.now, hours: -48)
    last7d_query = from r in accesses_query,
      where: r.time > ^Timex.shift(Timex.now, days: -7)
    last30d_query = from r in accesses_query,
      where: r.time > ^Timex.shift(Timex.now, days: -30)
    last1y_query = from r in accesses_query,
      where: r.time > ^Timex.shift(Timex.now, years: -1)

    last24h = Repo.one(last24h_query)
    last48h = Repo.one(last48h_query)
    last7d = Repo.one(last7d_query)
    last30d = Repo.one(last30d_query)
    last1y = Repo.one(last1y_query)
    all = Repo.one(accesses_query)
    total_requests = Repo.one(from r in HttpRequest, select: count(r.id))

    render(conn, "index.html",
      total_requests: total_requests,
      last24h: last24h,
      last48h: last48h,
      last7d: last7d,
      last30d: last30d,
      last1y: last1y,
      all: all
    )
  end
end

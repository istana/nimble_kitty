defmodule NimbleKittyWeb.PageController do
  use NimbleKittyWeb, :controller
  use Timex
  import Ecto.Query
  alias NimbleKitty.HttpRequest
  alias NimbleKitty.Repo

  def index(conn, _params) do
    accesses_query =
      from r in HttpRequest,
        select: count(r.id),
        where:
          not like(r.url, "%.ttf%") and
            not like(r.url, "%.css%") and
            not like(r.url, "%.js%") and
            not like(r.url, "%.jpg%") and
            not like(r.url, "%.jpeg%") and
            not like(r.url, "%.png%") and
            not like(r.url, "%.svg%") and
            r.status >= 200 and
            r.status < 300

    bots_query =
      from r in accesses_query,
        where:
          not is_nil(r.user_agent) and
            (like(r.user_agent, "%bot%") or like(r.user_agent, "%Bot%"))

    people_query =
      from r in accesses_query,
        where:
          is_nil(r.user_agent) or
            (not like(r.user_agent, "%bot%") and not like(r.user_agent, "%Bot%"))

    last24h_people_query =
      from r in people_query,
        where: r.time > ^Timex.shift(Timex.now(), hours: -24)

    last48h_people_query =
      from r in people_query,
        where: r.time > ^Timex.shift(Timex.now(), hours: -48)

    last7d_people_query =
      from r in people_query,
        where: r.time > ^Timex.shift(Timex.now(), days: -7)

    last30d_people_query =
      from r in people_query,
        where: r.time > ^Timex.shift(Timex.now(), days: -30)

    last1y_people_query =
      from r in people_query,
        where: r.time > ^Timex.shift(Timex.now(), years: -1)

    last24h_bots_query =
      from r in bots_query,
        where: r.time > ^Timex.shift(Timex.now(), hours: -24)

    last48h_bots_query =
      from r in bots_query,
        where: r.time > ^Timex.shift(Timex.now(), hours: -48)

    last7d_bots_query =
      from r in bots_query,
        where: r.time > ^Timex.shift(Timex.now(), days: -7)

    last30d_bots_query =
      from r in bots_query,
        where: r.time > ^Timex.shift(Timex.now(), days: -30)

    last1y_bots_query =
      from r in bots_query,
        where: r.time > ^Timex.shift(Timex.now(), years: -1)

    last24h_people = Repo.one(last24h_people_query)
    last48h_people = Repo.one(last48h_people_query)
    last7d_people = Repo.one(last7d_people_query)
    last30d_people = Repo.one(last30d_people_query)
    last1y_people = Repo.one(last1y_people_query)
    all_people = Repo.one(people_query)

    last24h_bots = Repo.one(last24h_bots_query)
    last48h_bots = Repo.one(last48h_bots_query)
    last7d_bots = Repo.one(last7d_bots_query)
    last30d_bots = Repo.one(last30d_bots_query)
    last1y_bots = Repo.one(last1y_bots_query)
    all_bots = Repo.one(bots_query)

    total_requests = Repo.one(from r in HttpRequest, select: count(r.id))

    render(conn, "index.html",
      last24h_people: last24h_people,
      last48h_people: last48h_people,
      last7d_people: last7d_people,
      last30d_people: last30d_people,
      last1y_people: last1y_people,
      all_people: all_people,
      last24h_bots: last24h_bots,
      last48h_bots: last48h_bots,
      last7d_bots: last7d_bots,
      last30d_bots: last30d_bots,
      last1y_bots: last1y_bots,
      all_bots: all_bots,
      total_requests: total_requests
    )
  end
end

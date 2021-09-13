defmodule NflRushingWeb.PlayerController do
  use NflRushingWeb, :controller

  alias NflRushing.Datasource
  alias NflRushing.Query

  @headers [
    "Player",
    "Team",
    "Pos",
    "Att/G",
    "Att",
    "Yds",
    "Avg",
    "Yds/G",
    "TD",
    "Lng",
    "1st",
    "1st%",
    "20+",
    "40+",
    "FUM"
  ]

  def export(conn, %{"q" => query, "sort" => sort}) do
    results =
      Datasource.all_players()
      |> Query.search(query, sort)
      |> Enum.map(fn p ->
        @headers |> Enum.map(fn h -> p[h] end)
      end)

    content =
      [@headers | results]
      |> NimbleCSV.RFC4180.dump_to_iodata()

    send_download(conn, {:binary, content}, filename: "players.csv", content_type: "text/csv")
  end
end

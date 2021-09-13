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

    filename = generate_filename(query, sort)

    send_download(conn, {:binary, content}, filename: filename, content_type: "text/csv")
  end

  defp generate_filename(query, sort) do
    with_query =
      case query do
        "" -> ""
        _ -> "_with_player_name_#{query}"
      end

    with_sort =
      case sort do
        %{"by" => ""} -> ""
        %{"by" => sort_by, "order" => order} -> "_sorted_by_#{sort_by}_#{order}"
      end

    "players#{with_query}#{with_sort}.csv"
  end
end

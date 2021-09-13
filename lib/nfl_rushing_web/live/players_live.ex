defmodule NflRushingWeb.PlayersLive do
  use NflRushingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    results = search()
    {:ok, assign(socket, query: "", results: results)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    results = search(query)
    {:noreply, assign(socket, results: results, query: query)}
  end

  def handle_event("sort", %{"by" => sort_by}, socket) do
    query = socket.assigns.query
    results = search(query, sort_by)
    {:noreply, assign(socket, results: results, query: query)}
  end

  defp search(), do: load_players()
  defp search(query) do
    search()
    |> Enum.filter(fn %{"Player" => player_name} ->
      String.contains?(String.downcase(player_name), String.downcase(query))
    end)
  end
  defp search(query, sort) do
    search(query)
    |> Enum.sort_by(fn p -> p[sort] end, :desc)
  end

  defp load_players() do
    filepath =
      :code.priv_dir(:nfl_rushing)
      |> Path.join("data/rushing.json")

    with contents <- File.read!(filepath),
         players <- Jason.decode!(contents) do
      players
    end
  end
end

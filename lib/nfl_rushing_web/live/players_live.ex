defmodule NflRushingWeb.PlayersLive do
  use NflRushingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    sort = %{"by" => nil, "order" => nil}
    results = search()
    {:ok, assign(socket, query: "", sort: sort, results: results)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    sort = socket.assigns.sort
    results = search(query, sort)
    {:noreply, assign(socket, query: query, sort: sort, results: results)}
  end

  def handle_event("sort", sort, socket) do
    query = socket.assigns.query
    results = search(query, sort)
    {:noreply, assign(socket, results: results, query: query, sort: sort)}
  end

  def handle_event("export", _values, socket) do
    query = socket.assigns.query
    sort = socket.assigns.sort
    results = search(query, sort)
    {:noreply, assign(socket, results: results, query: query, sort: sort)}
  end

  defp search(), do: load_players()

  defp search(query) do
    search()
    |> Enum.filter(fn %{"Player" => player_name} ->
      String.contains?(String.downcase(player_name), String.downcase(query))
    end)
  end

  defp search(query, %{"by" => nil, "order" => nil}), do: search(query)

  defp search(query, %{"by" => sort_by, "order" => order}) do
    search(query)
    |> Enum.sort_by(fn p -> parse_value(p[sort_by]) end, parse_order(order))
  end

  defp parse_value(v) when is_integer(v), do: v

  defp parse_value(v) when is_binary(v) do
    {value, _} = v |> String.replace(",", "") |> Integer.parse()

    value
  end

  defp parse_order("asc"), do: :asc
  defp parse_order("desc"), do: :desc

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

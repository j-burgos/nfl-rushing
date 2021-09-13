defmodule NflRushingWeb.PlayerLive do
  use NflRushingWeb, :live_view

  alias NflRushing.Datasource
  alias NflRushing.Query

  @impl true
  def mount(_params, _session, socket) do
    query = ""
    sort = %{"by" => "", "order" => ""}
    results = Datasource.all_players()
    {:ok, assign(socket, query: query, sort: sort, results: results)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, %{assigns: %{sort: sort}} = socket) do
    results = Datasource.all_players() |> Query.search(query, sort)
    {:noreply, assign(socket, query: query, sort: sort, results: results)}
  end

  @impl true
  def handle_event("sort", sort, %{assigns: %{query: query}} = socket) do
    results = Datasource.all_players() |> Query.search(query, sort)
    {:noreply, assign(socket, results: results, query: query, sort: sort)}
  end
end

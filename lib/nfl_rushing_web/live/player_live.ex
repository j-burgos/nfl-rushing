defmodule NflRushingWeb.PlayerLive do
  use NflRushingWeb, :live_view

  alias NflRushing.Datasource
  alias NflRushing.Query

  @impl true
  def mount(_params, _session, socket) do
    query = ""
    sort = %{"by" => "", "order" => ""}

    results =
      Datasource.all_players()
      |> Scrivener.paginate(page: 1, page_size: 20)

    {:ok, assign(socket, query: query, sort: sort, results: results)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, %{assigns: assigns} = socket) do
    %{sort: sort, results: results} = assigns

    new_results =
      Datasource.all_players()
      |> Query.search(query, sort)
      |> Scrivener.paginate(page: results.page_number, page_size: results.page_size)

    {:noreply, assign(socket, query: query, sort: sort, results: new_results)}
  end

  @impl true
  def handle_event("sort", sort, %{assigns: %{query: query, results: results}} = socket) do
    new_results =
      Datasource.all_players()
      |> Query.search(query, sort)
      |> Scrivener.paginate(page: results.page_number, page_size: results.page_size)

    {:noreply, assign(socket, results: new_results, query: query, sort: sort)}
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, %{assigns: assigns} = socket) do
    %{query: query, sort: sort, results: results} = assigns

    new_results =
      Datasource.all_players()
      |> Query.search(query, sort)
      |> Scrivener.paginate(page: page, page_size: results.page_size)

    {:noreply, assign(socket, results: new_results, query: query, sort: sort)}
  end
end

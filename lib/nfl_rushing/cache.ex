defmodule NflRushing.Cache do
  use GenServer

  require Logger

  @data_file "data/rushing.json"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def players() do
    GenServer.call(__MODULE__, :players)
  end

  @impl true
  def init(opts) do
    refresh_after_seconds = opts[:refresh_after_seconds]
    all_players = all_players()

    initial_state = %{
      players: all_players,
      refresh_after_seconds: refresh_after_seconds
    }

    Process.send_after(__MODULE__, :update_players, refresh_after_seconds * 1000)

    Logger.info("Cache started with data from #{@data_file}")
    Logger.info("Refreshing after #{refresh_after_seconds} seconds...")
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:players, _from, %{players: current_players} = state) do
    {:reply, current_players, state}
  end

  @impl true
  def handle_info(:update_players, %{refresh_after_seconds: refresh_time} = state) do
    Logger.info("Updating players from #{@data_file}...")
    updated_players = all_players()
    Process.send_after(__MODULE__, :update_players, refresh_time * 1000)
    {:noreply, %{state | players: updated_players}}
  end

  defp all_players() do
    filepath =
      :code.priv_dir(:nfl_rushing)
      |> Path.join(@data_file)

    with contents <- File.read!(filepath),
         players <- Jason.decode!(contents) do
      players
    end
  end
end

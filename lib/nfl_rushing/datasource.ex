defmodule NflRushing.Datasource do
  alias NflRushing.Cache
  def all_players(), do: Cache.players()
end

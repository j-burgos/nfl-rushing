defmodule NflRushing.Datasource do
  def all_players() do
    filepath =
      :code.priv_dir(:nfl_rushing)
      |> Path.join("data/rushing.json")

    with contents <- File.read!(filepath),
         players <- Jason.decode!(contents) do
      players
    end
  end
end

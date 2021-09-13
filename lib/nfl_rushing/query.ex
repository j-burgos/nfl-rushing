defmodule NflRushing.Query do
  def search(players, query) do
    players
    |> Enum.filter(fn %{"Player" => player_name} ->
      player_name
      |> String.downcase()
      |> String.contains?(String.downcase(query))
    end)
  end

  def search(players, query, %{"by" => "", "order" => ""}), do: search(players, query)

  def search(players, query, %{"by" => sort_by, "order" => order}) do
    search(players, query)
    |> Enum.sort_by(fn p -> parse_value(p[sort_by]) end, parse_order(order))
  end

  defp parse_value(v) when is_integer(v), do: v

  defp parse_value(v) when is_binary(v) do
    {value, t} = v |> String.replace(",", "") |> Integer.parse()

    case t do
      # Longest Rush with a touchdown has more value
      "T" -> value + 0.1
      _ -> value
    end
  end

  defp parse_order("asc"), do: :asc
  defp parse_order("desc"), do: :desc
end

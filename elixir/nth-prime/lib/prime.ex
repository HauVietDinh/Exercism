defmodule Prime do
  @doc """
  Generates the nth prime.
  """
  @spec nth(pos_integer()) :: pos_integer()
  def nth(count) when count >= 1 do
    Stream.iterate(2, &(&1 + 1))
    |> Stream.filter(&prime?/1)
    |> Enum.at(count - 1)
  end

  defp prime?(2), do: true
  defp prime?(number) when number < 2 or rem(number, 2) == 0, do: false
  defp prime?(number) do
    Enum.all?(3..trunc(:math.sqrt(number))//2, fn n -> rem(number, n) != 0 end)
  end
end

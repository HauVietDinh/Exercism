defmodule Series do
  @doc """
  Finds the largest product of a given number of consecutive numbers in a given string of numbers.
  """
  @spec largest_product(String.t(), non_neg_integer) :: non_neg_integer
  def largest_product(number_string, size) do
    if String.length(number_string) < size or size < 1 do
      raise ArgumentError
    else
      number_string
      |> String.graphemes()
      |> Enum.chunk_every(size, 1, :discard)
      |> Enum.map(&Enum.product_by(&1, fn x -> String.to_integer(x) end))
      |> Enum.max()
    end
  end
end

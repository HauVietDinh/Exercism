defmodule PalindromeProducts do
  @doc """
  Generates all palindrome products from an optionally given min factor (or 1) to a given max factor.
  """
  @spec generate(non_neg_integer, non_neg_integer) :: map
  def generate(max_factor, min_factor \\ 1)

  def generate(max_factor, min_factor) when max_factor < min_factor do
    raise ArgumentError, "max_factor must be greater than or equal to min_factor"
  end

  def generate(max_factor, min_factor) do
    min_factor..max_factor
    |> Enum.flat_map(fn x ->
      Enum.map(x..max_factor, fn y -> {x, y} end)
    end)
    |> Enum.map(fn {x, y} -> {x * y, [x, y]} end)
    |> Enum.filter(fn {product, _factors} -> is_palindrome?(product) end)
    |> Enum.group_by(fn {product, _factors} -> product end, fn {_product, factors} -> factors end)
  end

  defp is_palindrome?(n) do
    s = Integer.to_string(n)
    s == String.reverse(s)
  end
end

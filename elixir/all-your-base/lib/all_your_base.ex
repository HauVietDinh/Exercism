defmodule AllYourBase do
  @doc """
  Given a number in input base, represented as a sequence of digits, converts it to output base,
  or returns an error tuple if either of the bases are less than 2
  """

  @spec convert(list, integer, integer) :: {:ok, list} | {:error, String.t()}
  def convert(_digits, input_base, _output_base) when input_base < 2 do
    {:error, "input base must be >= 2"}
  end

  def convert(_digits, _input_base, output_base) when output_base < 2 do
    {:error, "output base must be >= 2"}
  end

  def convert(digits, input_base, output_base) do
    with {:ok, decimal} <- to_decimal(digits, input_base),
         {:ok, converted} <- from_decimal(decimal, output_base) do
      {:ok, converted}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp to_decimal(digits, base) do
    if Enum.any?(digits, fn d -> d < 0 or d >= base end) do
      {:error, "all digits must be >= 0 and < input base"}
    else
      decimal = Enum.reduce(digits, 0, fn d, acc -> acc * base + d end)
      {:ok, decimal}
    end
  end

  defp from_decimal(0, _base), do: {:ok, [0]}

  defp from_decimal(decimal, base) do
    digits =
      Stream.unfold(decimal, fn n ->
        if n == 0 do
          nil
        else
          {rem(n, base), div(n, base)}
        end
      end)
      |> Enum.to_list()
      |> Enum.reverse()

    {:ok, digits}
  end
end

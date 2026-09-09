defmodule ArmstrongNumber do
  @moduledoc """
  Provides a way to validate whether or not a number is an Armstrong number
  """

  @spec valid?(integer) :: boolean
  def valid?(number) when is_integer(number) do
    number
    |> Integer.digits()
    |> then(fn digits ->
      length = length(digits)
      Enum.sum_by(digits, &(&1 ** length)) == number
    end)
  end
end

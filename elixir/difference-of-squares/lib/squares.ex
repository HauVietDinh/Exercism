defmodule Squares do
  @moduledoc """
  Calculate sum of squares, square of sum, difference between two sums from 1 to a given end number.
  """

  @doc """
  Calculate sum of squares from 1 to a given end number.
  """
  @spec sum_of_squares(pos_integer) :: pos_integer
  def sum_of_squares(number) when is_integer(number) and number > 0 do
    Enum.sum(Enum.map(1..number, &(&1 * &1)))
  end

  @doc """
  Calculate square of sum from 1 to a given end number.
  """
  @spec square_of_sum(pos_integer) :: pos_integer
  def square_of_sum(number) when is_integer(number) and number > 0 do
    Enum.sum(1..number) ** 2
  end

  @doc """
  Calculate difference between sum of squares and square of sum from 1 to a given end number.
  """
  @spec difference(pos_integer) :: pos_integer
  def difference(number) when is_integer(number) and number > 0 do
    square_of_sum(number) - sum_of_squares(number)
  end
end

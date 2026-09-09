defmodule Meetup do
  @moduledoc """
  Calculate meetup dates.
  """

  @type weekday ::
          :monday
          | :tuesday
          | :wednesday
          | :thursday
          | :friday
          | :saturday
          | :sunday

  @type schedule :: :first | :second | :third | :fourth | :last | :teenth

  @doc """
  Calculate a meetup date.

  The schedule is in which week (1..4, last or "teenth") the meetup date should
  fall.
  """
  @spec meetup(pos_integer, pos_integer, weekday, schedule) :: Date.t()
  def meetup(year, month, weekday, schedule) do
    days =
      Date.range(
        Date.new!(year, month, 1),
        Date.new!(year, month, Date.days_in_month(Date.new!(year, month, 1)))
      )
      |> Enum.filter(fn date -> Date.day_of_week(date) == weekday_to_number(weekday) end)

    case schedule do
      :first -> Enum.at(days, 0)
      :second -> Enum.at(days, 1)
      :third -> Enum.at(days, 2)
      :fourth -> Enum.at(days, 3)
      :last -> List.last(days)
      :teenth -> Enum.find(days, fn date -> date.day in 13..19 end)
    end
  end

  defp weekday_to_number(weekday) do
    case weekday do
      :monday -> 1
      :tuesday -> 2
      :wednesday -> 3
      :thursday -> 4
      :friday -> 5
      :saturday -> 6
      :sunday -> 7
    end
  end
end

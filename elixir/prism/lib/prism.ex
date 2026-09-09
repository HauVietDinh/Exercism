defmodule Prism do
  @type start :: %{angle: number(), x: number(), y: number()}
  @type prism :: %{id: integer(), angle: number(), x: number(), y: number()}

  @epsilon 1.0e-2

  @spec find_sequence(prisms :: [prism()], start :: start()) :: [integer()]
  def find_sequence(prisms, start) do
    do_find_sequence(prisms, start, [])
  end

  defp do_find_sequence([], _current, sequence) do
    Enum.reverse(sequence)
  end

  defp do_find_sequence(prisms, current, sequence) do
    case find_next_prism(prisms, current) do
      nil ->
        Enum.reverse(sequence)

      prism ->
        current = %{
          x: prism.x,
          y: prism.y,
          angle: current.angle + prism.angle
        }

        do_find_sequence(prisms, current, [prism.id | sequence])
    end
  end

  defp find_next_prism(prisms, %{x: x, y: y, angle: angle}) do
    prisms
    |> Enum.reduce(nil, fn prism, best ->
      if same_position?(prism, x, y) do
        best
      else
        angle_to_prism =
          :math.atan2(prism.y - y, prism.x - x)
          |> radians_to_degrees()

        if angle_difference(angle_to_prism, angle) < @epsilon do
          distance = distance_squared(prism.x - x, prism.y - y)

          case best do
            nil -> {prism, distance}
            {_, best_distance} when distance < best_distance -> {prism, distance}
            _ -> best
          end
        else
          best
        end
      end
    end)
    |> case do
      nil -> nil
      {prism, _distance} -> prism
    end
  end

  defp same_position?(%{x: px, y: py}, x, y) do
    abs(px - x) < @epsilon and abs(py - y) < @epsilon
  end

  defp distance_squared(x, y) do
    x * x + y * y
  end

  defp radians_to_degrees(radians) do
    radians * 180 / :math.pi()
  end

  defp angle_difference(a, b) do
    difference = rem_float(a - b + 180, 360) - 180
    abs(difference)
  end

  defp rem_float(value, divisor) do
    value - Float.floor(value / divisor) * divisor
  end
end

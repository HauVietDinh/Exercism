defmodule StateOfTicTacToe do
  @doc """
  Determine the state a game of tic-tac-toe where X starts.
  """
  @spec game_state(board :: String.t()) :: {:ok, :win | :ongoing | :draw} | {:error, String.t()}
  def game_state(board) do
    String.split(board, "\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> check_board()
  end

  defp check_board(board) do
    case validate_board(board) do
      :ok ->
        case check_winner(board) do
          :win -> {:ok, :win}
          :draw -> {:ok, :draw}
          :ongoing -> {:ok, :ongoing}
          {:error, reason} -> {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp validate_board(board) do
    {x, o} =
      Enum.reduce(board, {0, 0}, fn row, {x_count, o_count} ->
        {x_count + Enum.count(row, &(&1 == "X")), o_count + Enum.count(row, &(&1 == "O"))}
      end)

    cond do
      x < o ->
        {:error, "Wrong turn order: O started"}

      x > o + 1 ->
        {:error, "Wrong turn order: X went twice"}

      true ->
        :ok
    end
  end

  defp check_winner(board) do
    columns = Enum.zip(board) |> Enum.map(&Tuple.to_list/1)
    diagonals = diagonals(board)
    lines = board ++ columns ++ diagonals

    cond do
      Enum.any?(lines, &(&1 == ["X", "X", "X"])) and
          Enum.any?(lines, &(&1 == ["O", "O", "O"])) ->
        {:error,
         "Impossible board: game should have ended" <>
           " after the game was won"}

      Enum.any?(lines, &(&1 == ["X", "X", "X"])) ->
        :win

      Enum.any?(lines, &(&1 == ["O", "O", "O"])) ->
        :win

      Enum.all?(board, fn row -> Enum.all?(row, &(&1 != ".")) end) ->
        :draw

      true ->
        :ongoing
    end
  end

  defp diagonals(board) do
    [
      [
        Enum.at(Enum.at(board, 0), 0),
        Enum.at(Enum.at(board, 1), 1),
        Enum.at(Enum.at(board, 2), 2)
      ],
      [
        Enum.at(Enum.at(board, 0), 2),
        Enum.at(Enum.at(board, 1), 1),
        Enum.at(Enum.at(board, 2), 0)
      ]
    ]
  end
end

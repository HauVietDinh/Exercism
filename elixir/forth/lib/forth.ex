defmodule Forth do
  alias Forth.{StackUnderflow, InvalidWord, UnknownWord, DivisionByZero}

  @type evaluator :: %Forth{stack: list(), words: map()}

  defstruct stack: [], words: %{}
  @doc """
  Create a new evaluator.
  """
  @spec new() :: evaluator
  def new do
    %Forth{stack: [], words: built_in_words()}
  end

  defp built_in_words do
    %{
      "+" => fn
        [a, b | rest] -> [b + a | rest]
        _ -> raise StackUnderflow
      end,
      "-" => fn
        [a, b | rest] -> [b - a | rest]
        _ -> raise StackUnderflow
      end,
      "*" => fn
        [a, b | rest] -> [b * a | rest]
        _ -> raise StackUnderflow
      end,
      "/" => fn
        [0, _b | _rest] -> raise DivisionByZero
        [a, b | rest] -> [div(b, a) | rest]
        _ -> raise StackUnderflow
      end,
      "dup" => fn
        [a | rest] -> [a, a | rest]
        [] -> raise StackUnderflow
      end,
      "drop" => fn
        [_a | rest] -> rest
        [] -> raise StackUnderflow
      end,
      "swap" => fn
        [a, b | rest] -> [b, a | rest]
        _ -> raise StackUnderflow
      end,
      "over" => fn
        [a, b | rest] ->
          [b, a, b | rest]
        _ ->
          raise StackUnderflow
      end
    }
  end

  @doc """
  Evaluate an input string, updating the evaluator state.
  """
  @spec eval(evaluator, String.t()) :: evaluator
  def eval(%Forth{} = ev, ":" <> s) do
    [new_word | rest] = String.split(s, ";", trim: true)
    [word | definition] = String.split(new_word, ~r/\s+/, trim: true)
    if numeric?(word) do
      raise InvalidWord, word: word
    end
    definition =
      definition
      |> Enum.map(&String.downcase/1)
      |> expand_definition(ev.words)

    words = Map.put(ev.words, String.downcase(word), definition)

    if rest == [] do
      %Forth{ev | words: words}
    else
      rest
      |> Enum.join(" ")
      |> then(&eval(%Forth{ev | words: words}, &1))
    end
  end

  def eval(%Forth{} = ev, input) do
    input
    |> String.split(~r/[[:space:]|[:cntrl:]]/u, trim: true)
    |> eval_words(ev)
  end

  defp numeric?(word) do
    case Integer.parse(word) do
      {_number, ""} -> true
      _ -> false
    end
  end

  defp expand_definition(definition, words) do
    Enum.flat_map(definition, fn word ->
      case Map.get(words, word) do
        definition when is_list(definition) -> definition
        fun when is_function(fun) -> [fun]
        nil -> [word]
      end
    end)
  end

  defp eval_words([], %Forth{} = ev), do: ev
  defp eval_words([word | rest], %Forth{} = ev) do
    case word do
      word when is_binary(word) ->
        case Integer.parse(word) do
          {number, ""} ->
            eval_words(rest, %Forth{ev | stack: [number | ev.stack]})
          _ ->
            execute_word(word, rest, ev)
        end
      fun when is_function(fun) ->
        execute_word(fun, rest, ev)
    end
  end

  defp execute_word(fun, rest, %Forth{} = ev) when is_function(fun) do
    eval_words(rest, %Forth{ev | stack: fun.(ev.stack)})
  end

  defp execute_word(word, rest, %Forth{} = ev) do
    case Map.get(ev.words, String.downcase(word)) do
      nil ->
        raise UnknownWord, word: word
      definition when is_list(definition) ->
        eval_words(definition ++ rest, ev)
      fun when is_function(fun) ->
        execute_word(fun, rest, ev)
    end
  end

  @doc """
  Return the current stack as a string with the element on top of the stack
  being the rightmost element in the string.
  """
  @spec format_stack(evaluator) :: String.t()
  def format_stack(%Forth{} = ev) do
    ev.stack
    |> Enum.reverse()
    |> Enum.join(" ")
  end

  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception word: nil
    def message(e), do: "invalid word: #{inspect(e.word)}"
  end

  defmodule UnknownWord do
    defexception word: nil
    def message(e), do: "unknown word: #{inspect(e.word)}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end
end

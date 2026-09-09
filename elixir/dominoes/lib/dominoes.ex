defmodule Dominoes do
  @type domino :: {1..6, 1..6}

  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino]) :: boolean
  def chain?([]), do: true
  def chain?([{a, b}]), do: a == b

  def chain?([{a, b} | dominoes]) do
    Enum.any?(
      dominoes,
      fn
        {^a, any} = domino -> chain?([{any, b} | List.delete(dominoes, domino)])
        {any, ^a} = domino -> chain?([{any, b} | List.delete(dominoes, domino)])
        _ -> false
      end
    )
  end
end

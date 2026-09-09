defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, 'base'.
  """
  @spec match(String.t(), [String.t()]) :: [String.t()]
  def match(base, candidates) do
    upper_base = String.upcase(base)
    sorted_base = sort_chars(upper_base)

    Enum.filter(candidates, fn candidate ->
      upper_candidate = String.upcase(candidate)

      sorted_base == sort_chars(upper_candidate) and
        upper_candidate != upper_base
    end)
  end

  defp sort_chars(word) do
    word
    |> String.to_charlist()
    |> Enum.sort()
  end
end

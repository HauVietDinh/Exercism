defmodule Bob do
  @spec hey(String.t()) :: String.t()
  def hey(input) do
    input = String.trim(input)
    cond do
      String.ends_with?(input, "?") and yelling?(input) ->
        "Calm down, I know what I'm doing!"
      String.ends_with?(input, "?") ->
        "Sure."
      yelling?(input) ->
        "Whoa, chill out!"
      String.match?(input, ~r/^\s*$/) ->
        "Fine. Be that way!"
      true ->
        "Whatever."
    end
  end

  defp yelling?(input) do
    letters = Regex.replace(~r/[^\p{L}]/u, input, "")

    letters != "" and letters == String.upcase(letters)
  end
end

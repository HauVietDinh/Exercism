defmodule Grep do
  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, files) do
    multi_file? = length(files) > 1

    files
    |> Enum.flat_map(&process_file(pattern, flags, &1, multi_file?))
    |> Enum.join("")
  end

  defp process_file(pattern, flags, file, multi_file?) do
    regex = compile_regex(pattern, flags)
    invert? = "-v" in flags
    line_numbers? = "-n" in flags
    only_names? = "-l" in flags
    prefix_file? = multi_file?

    case File.read(file) do
      {:ok, content} ->
        lines = String.split(content, ~r/\r?\n/, trim: true)

        matches =
          lines
          |> Enum.with_index(1)
          |> Enum.filter(fn {line, _num} ->
            matched? = Regex.match?(regex, line)
            if invert?, do: not matched?, else: matched?
          end)

        if only_names? and matches != [] do
          [file <> "\n"]
        else
          Enum.map(matches, fn {line, num} ->
            format_line(file, num, line, prefix_file?, line_numbers?)
          end)
        end

      {:error, _} ->
        []
    end
  end

  defp compile_regex(pattern, flags) do
    case_insensitive? = "-i" in flags
    entire_line? = "-x" in flags

    source = if entire_line?, do: "^#{pattern}$", else: pattern
    opts = if case_insensitive?, do: [:caseless], else: []

    Regex.compile!(source, opts)
  end

  defp format_line(file, num, line, prefix_file?, line_numbers?) do
    prefix =
      [
        if(prefix_file?, do: file),
        if(line_numbers?, do: Integer.to_string(num))
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(":")

    if prefix == "", do: line <> "\n", else: prefix <> ":" <> line <> "\n"
  end
end

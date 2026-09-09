defmodule Transmission do
  import Bitwise

  @doc """
  Return the transmission sequence for a message.
  """
  @spec get_transmit_sequence(binary()) :: binary()
  def get_transmit_sequence(message) do
    message
    |> :binary.bin_to_list()
    |> Enum.flat_map(fn byte ->
      for bit <- 7..0//-1, do: byte >>> bit &&& 1
    end)
    |> Enum.chunk_every(7)
    |> Enum.map(&add_parity_bit/1)
    |> Enum.map(&bits_to_byte/1)
    |> :binary.list_to_bin()
  end

  defp add_parity_bit(bits) do
    bits = bits ++ List.duplicate(0, 7 - length(bits))
    parity = Enum.sum(bits) |> rem(2)
    bits ++ [parity]
  end

  defp bits_to_byte(bits) do
    Enum.reduce(bits, 0, fn bit, byte ->
      byte <<< 1 ||| bit
    end)
  end

  @doc """
  Return the message decoded from the received transmission.
  """
  @spec decode_message(binary()) :: {:ok, binary()} | {:error, String.t()}
  def decode_message(received_data) do
    if rem(byte_size(received_data), 1) != 0 do
      {:error, "invalid transmission length"}
    else
      received_data
      |> :binary.bin_to_list()
      |> Enum.reduce_while([], &decode_byte/2)
      |> case do
        {:error, reason} -> {:error, reason}
        bits -> {:ok, bits_to_binary(bits)}
      end
    end
  end

  defp decode_byte(byte, acc) do
    bits =
      for bit <- 7..0//-1 do
        byte >>> bit &&& 1
      end

    {data, [parity]} = Enum.split(bits, 7)

    if rem(Enum.sum(data) + parity, 2) == 0 do
      {:cont, acc ++ data}
    else
      {:halt, {:error, "wrong parity"}}
    end
  end

  defp bits_to_binary(bits) do
    bits
    |> Enum.chunk_every(8, 8, :discard)
    |> Enum.map(&bits_to_byte/1)
    |> :binary.list_to_bin()
  end
end

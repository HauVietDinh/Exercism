defmodule SecretHandshake do
  @doc """
  Determine the actions of a secret handshake based on the binary
  representation of the given `code`.

  If the following bits are set, include the corresponding action in your list
  of commands, in order from lowest to highest.

  1 = wink
  10 = double blink
  100 = close your eyes
  1000 = jump

  10000 = Reverse the order of the operations in the secret handshake
  """
  @spec commands(code :: integer) :: list(String.t())
  def commands(code) do
    <<reverse::1, jump::1, close_eyes::1, double_blink::1, wink::1>> = <<code::5>>

    action_map = [
      {wink, "wink"},
      {double_blink, "double blink"},
      {close_eyes, "close your eyes"},
      {jump, "jump"}
    ]

    actions = for {1, action} <- action_map, do: action
    if reverse == 1, do: Enum.reverse(actions), else: actions
  end
end

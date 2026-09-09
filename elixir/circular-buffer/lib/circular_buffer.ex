defmodule CircularBuffer do
  @moduledoc """
  An API to a stateful process that fills and empties a circular buffer
  """
  use GenServer

  @type state :: %__MODULE__{
          buffer: map(),
          oldest: pos_integer(),
          next: pos_integer(),
          size: non_neg_integer(),
          capacity: nil | pos_integer()
        }

  defstruct buffer: %{},
            oldest: 1,
            next: 1,
            size: 0,
            capacity: nil

  @doc """
  Create a new buffer of a given capacity
  """
  @spec new(capacity :: integer) :: {:ok, pid}
  def new(capacity) when is_integer(capacity) and capacity > 0 do
    GenServer.start_link(__MODULE__, capacity)
  end

  @doc """
  Read the oldest entry in the buffer, fail if it is empty
  """
  @spec read(buffer :: pid) :: {:ok, any} | {:error, atom}
  def read(buffer) do
    GenServer.call(buffer, :read)
  end

  @doc """
  Write a new item in the buffer, fail if is full
  """
  @spec write(buffer :: pid, item :: any) :: :ok | {:error, atom}
  def write(buffer, item) do
    GenServer.call(buffer, {:write, item})
  end

  @doc """
  Write an item in the buffer, overwrite the oldest entry if it is full
  """
  @spec overwrite(buffer :: pid, item :: any) :: :ok
  def overwrite(buffer, item) do
    GenServer.call(buffer, {:overwrite, item})
  end

  @doc """
  Clear the buffer
  """
  @spec clear(buffer :: pid) :: :ok
  def clear(buffer) do
    GenServer.cast(buffer, :clear)
  end

  # Server callbacks

  @impl GenServer
  def init(capacity) do
    buffer =
      1..capacity
      |> Enum.reduce(%{}, &Map.put(&2, &1, nil))

    {:ok, %__MODULE__{buffer: buffer, capacity: capacity}}
  end

  @impl GenServer
  def handle_call(
        :read,
        _from,
        %__MODULE__{
          buffer: buffer,
          oldest: oldest,
          size: size,
          capacity: capacity
        } = state
      ) do
    buffer_value = buffer[oldest]

    {reply, new_state} =
      if buffer_value == nil do
        {{:error, :empty}, state}
      else
        {{:ok, buffer_value},
         %{
           state
           | buffer: %{buffer | oldest => nil},
             oldest: next(oldest, capacity),
             size: size - 1
         }}
      end

    {:reply, reply, new_state}
  end

  @impl GenServer
  def handle_call(
        {:write, item},
        _from,
        %__MODULE__{
          buffer: buffer,
          next: next,
          size: size,
          capacity: capacity
        } = state
      ) do
    if size == capacity do
      {:reply, {:error, :full}, state}
    else
      {:reply, :ok,
       %{
         state
         | buffer: %{buffer | next => item},
           size: size + 1,
           next: next(next, capacity)
       }}
    end
  end

  @impl GenServer
  def handle_call(
        {:overwrite, item},
        _from,
        %__MODULE__{
          buffer: buffer,
          next: next,
          size: size,
          oldest: oldest,
          capacity: capacity
        } = state
      ) do
    if size == capacity do
      {:reply, :ok,
       %{
         state
         | buffer: %{buffer | next => item},
           next: next(next, capacity),
           oldest: next(oldest, capacity)
       }}
    else
      {:reply, :ok,
       %{
         state
         | buffer: %{buffer | next => item},
           size: size + 1,
           next: next(next, capacity)
       }}
    end
  end

  @impl GenServer
  def handle_cast(:clear, %__MODULE__{buffer: buffer, capacity: capacity}) do
    buffer =
      buffer
      |> Enum.map(fn {key, _} -> {key, nil} end)
      |> Enum.into(%{})

    {:noreply, %__MODULE__{buffer: buffer, capacity: capacity}}
  end

  defp next(current, capacity) do
    if current == capacity, do: 1, else: current + 1
  end
end

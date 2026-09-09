defmodule React do
  use GenServer

  @opaque cells :: pid

  @type cell :: {:input, String.t(), any} | {:output, String.t(), [String.t()], fun()}
  @type callback :: (String.t(), any() -> any())

  defstruct cells: %{},
            values: %{},
            callbacks: %{}

  @doc """
  Start a reactive system
  """
  @spec new(cells :: [cell]) :: {:ok, pid}
  def new(cells) do
    GenServer.start(__MODULE__, cells)
  end

  @doc """
  Return the value of an input or output cell
  """
  @spec get_value(cells :: pid, cell_name :: String.t()) :: any()
  def get_value(cells, cell_name) do
    GenServer.call(cells, {:get_value, cell_name})
  end

  @doc """
  Set the value of an input cell
  """
  @spec set_value(cells :: pid, cell_name :: String.t(), value :: any) :: :ok
  def set_value(cells, cell_name, value) do
    GenServer.cast(cells, {:set_value, cell_name, value})
  end

  @doc """
  Add a callback to an output cell
  """
  @spec add_callback(
          cells :: pid,
          cell_name :: String.t(),
          callback_name :: String.t(),
          callback :: fun()
        ) :: :ok
  def add_callback(cells, cell_name, callback_name, callback) do
    GenServer.cast(cells, {:add_callback, cell_name, callback_name, callback})
  end

  @doc """
  Remove a callback from an output cell
  """
  @spec remove_callback(cells :: pid, cell_name :: String.t(), callback_name :: String.t()) :: :ok
  def remove_callback(cells, cell_name, callback_name) do
    GenServer.cast(cells, {:remove_callback, cell_name, callback_name})
  end

  # Server callbacks

  @impl GenServer
  def init(cells) do
    cells = Map.new(cells, &cell_entry/1)
    {:ok, %__MODULE__{cells: cells, values: evaluate_cells(cells)}}
  end

  @impl GenServer
  def handle_call({:get_value, cell_name}, _from, %__MODULE__{values: values} = state) do
    value = Map.get(values, cell_name, {:error, :not_found})
    {:reply, value, state}
  end

  defp cell_entry({:input, cell_name, value}), do: {cell_name, {:input, value}}
  defp cell_entry({:output, cell_name, inputs, fun}), do: {cell_name, {:output, inputs, fun}}

  defp evaluate_cells(cells) do
    Enum.reduce(Map.keys(cells), %{}, fn cell_name, values ->
      {_value, values} = evaluate(cell_name, cells, values, MapSet.new())
      values
    end)
  end

  defp evaluate(cell_name, _cells, values, _visiting) when is_map_key(values, cell_name) do
    {Map.fetch!(values, cell_name), values}
  end

  defp evaluate(cell_name, cells, values, visiting) do
    if MapSet.member?(visiting, cell_name) do
      raise ArgumentError, "cyclic cell dependency involving #{inspect(cell_name)}"
    end

    case Map.get(cells, cell_name) do
      {:input, value} ->
        {value, Map.put(values, cell_name, value)}

      {:output, inputs, fun} ->
        visiting = MapSet.put(visiting, cell_name)

        {input_values, values} =
          Enum.map_reduce(inputs, values, fn input, values ->
            evaluate(input, cells, values, visiting)
          end)

        value = apply(fun, input_values)
        {value, Map.put(values, cell_name, value)}

      nil ->
        {{:error, :not_found}, values}
    end
  end

  @impl GenServer
  def handle_cast(
        {:set_value, cell_name, value},
        %__MODULE__{cells: cells, values: old_values, callbacks: callbacks} = state
      ) do
    new_cells = Map.put(cells, cell_name, {:input, value})
    new_values = evaluate_cells(new_cells)

    notify_changed_callbacks(new_cells, old_values, new_values, callbacks)

    {:noreply, %{state | cells: new_cells, values: new_values}}
  end

  @impl GenServer
  def handle_cast(
        {:add_callback, cell_name, callback_name, callback},
        %__MODULE__{callbacks: callbacks} = state
      ) do
    callbacks = Map.put(callbacks, {cell_name, callback_name}, callback)
    {:noreply, %{state | callbacks: callbacks}}
  end

  @impl GenServer
  def handle_cast(
        {:remove_callback, cell_name, callback_name},
        %__MODULE__{callbacks: callbacks} = state
      ) do
    callbacks = Map.delete(callbacks, {cell_name, callback_name})
    {:noreply, %{state | callbacks: callbacks}}
  end

  defp notify_changed_callbacks(cells, old_values, new_values, callbacks) do
    for {cell_name, {:output, _inputs, _fun}} <- cells,
        Map.get(old_values, cell_name, {:error, :not_found}) !=
          Map.get(new_values, cell_name, {:error, :not_found}) do
      new_value = Map.fetch!(new_values, cell_name)

      for {{^cell_name, callback_name}, callback} <- callbacks do
        callback.(callback_name, new_value)
      end
    end
  end
end

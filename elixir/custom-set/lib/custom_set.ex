defmodule CustomSet do
  @opaque t :: %__MODULE__{map: map}

  defstruct map: %{}

  @spec new(Enum.t()) :: t
  def new(enumerable) do
    Enum.reduce(enumerable, %__MODULE__{map: %{}}, fn element, %__MODULE__{map: acc_map} ->
      %__MODULE__{map: Map.put(acc_map, element, true)}
    end)
  end

  @spec empty?(t) :: boolean
  def empty?(%__MODULE__{map: map}) do
    map_size(map) == 0
  end

  @spec contains?(t, any) :: boolean
  def contains?(%__MODULE__{map: map}, element) do
    Map.has_key?(map, element)
  end

  @spec subset?(t, t) :: boolean
  def subset?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    Enum.all?(map1, fn {element, _} -> Map.has_key?(map2, element) end)
  end

  @spec disjoint?(t, t) :: boolean
  def disjoint?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    Enum.all?(map1, fn {element, _} -> not Map.has_key?(map2, element) end)
  end

  @spec equal?(t, t) :: boolean
  def equal?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    subset?(%__MODULE__{map: map1}, %__MODULE__{map: map2}) and
      subset?(%__MODULE__{map: map2}, %__MODULE__{map: map1})
  end

  @spec add(t, any) :: t
  def add(%__MODULE__{map: map} = custom_set, element) do
    %__MODULE__{custom_set | map: Map.put(map, element, true)}
  end

  @spec intersection(t, t) :: t
  def intersection(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    new_map =
      Enum.reduce(map1, %{}, fn {element, _}, acc ->
        if Map.has_key?(map2, element) do
          Map.put(acc, element, true)
        else
          acc
        end
      end)

    %__MODULE__{map: new_map}
  end

  @spec difference(t, t) :: t
  def difference(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    new_map =
      Enum.reduce(map1, %{}, fn {element, _}, acc ->
        if not Map.has_key?(map2, element) do
          Map.put(acc, element, true)
        else
          acc
        end
      end)

    %__MODULE__{map: new_map}
  end

  @spec union(t, t) :: t
  def union(%__MODULE__{map: map1}, %__MODULE__{map: map2}) do
    new_map =
      Enum.reduce(map1, map2, fn {element, _}, acc ->
        Map.put(acc, element, true)
      end)

    %__MODULE__{map: new_map}
  end
end

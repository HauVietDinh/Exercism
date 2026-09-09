defmodule SplitSecondStopwatch do
  @doc """
  A stopwatch that can be used to track lap times.
  """

  @type state :: :ready | :running | :stopped

  defmodule Stopwatch do
    @type t :: %__MODULE__{
            state: SplitSecondStopwatch.state(),
            time: Time.t(),
            current_lap: Time.t(),
            previous_laps: list(Time.t()),
            total: Time.t()
          }
    defstruct state: :ready,
              time: Time.new!(0, 0, 0),
              current_lap: Time.new!(0, 0, 0),
              previous_laps: [],
              total: Time.new!(0, 0, 0)
  end

  @spec new() :: Stopwatch.t()
  def new() do
    %Stopwatch{}
  end

  @spec state(Stopwatch.t()) :: state()
  def state(%Stopwatch{state: state}) do
    state
  end

  @spec current_lap(Stopwatch.t()) :: Time.t()
  def current_lap(%Stopwatch{current_lap: current_lap}) do
    current_lap
  end

  @spec previous_laps(Stopwatch.t()) :: [Time.t()]
  def previous_laps(%Stopwatch{previous_laps: previous_laps}) do
    previous_laps
  end

  @spec advance_time(Stopwatch.t(), Time.t()) :: Stopwatch.t()
  def advance_time(
        %Stopwatch{
          state: :running,
          current_lap: current_lap,
          total: total
        } = stopwatch,
        time
      ) do
    seconds = Time.diff(time, ~T[00:00:00], :second)

    %Stopwatch{
      stopwatch
      | current_lap: Time.add(current_lap, seconds),
        total: Time.add(total, seconds)
    }
  end

  def advance_time(stopwatch, _), do: stopwatch

  @spec total(Stopwatch.t()) :: Time.t()
  def total(%Stopwatch{total: total}) do
    total
  end

  @spec start(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def start(%Stopwatch{state: :running}) do
    {:error, "cannot start an already running stopwatch"}
  end

  def start(%Stopwatch{} = stopwatch) do
    %Stopwatch{stopwatch | state: :running}
  end

  @spec stop(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def stop(%Stopwatch{state: :running} = stopwatch) do
    %Stopwatch{stopwatch | state: :stopped}
  end

  def stop(_) do
    {:error, "cannot stop a stopwatch that is not running"}
  end

  @spec lap(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def lap(
        %Stopwatch{
          state: :running,
          current_lap: current_lap,
          previous_laps: previous_laps
        } = stopwatch
      ) do
    %Stopwatch{
      stopwatch
      | current_lap: ~T[00:00:00],
        previous_laps: previous_laps ++ [current_lap]
    }
  end

  def lap(_) do
    {:error, "cannot lap a stopwatch that is not running"}
  end

  @spec reset(Stopwatch.t()) :: Stopwatch.t() | {:error, String.t()}
  def reset(%Stopwatch{state: :stopped}) do
    new()
  end

  def reset(_) do
    {:error, "cannot reset a stopwatch that is not stopped"}
  end
end

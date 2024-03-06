defmodule UrlShortener.Urls.FourByteIdSequencer do
  @moduledoc """
  This sequencer generates an integer that can be fit in 4 bytes (default Postgres int size).

  The maximum value is set to the max signed 4-byte int value.
  """
  alias UrlShortener.Behaviors.UniqueIdSequencer

  @behaviour UniqueIdSequencer

  # This is the max value for a signed 4 byte integer
  @max 2_147_483_647

  @impl true
  def get_unique_id, do: Enum.random(1..@max)

  @impl true
  def max, do: @max
end

defmodule UrlShortener.Behaviors.UniqueIdSequencer do
  @moduledoc """
  This module defines the behavior for generating a random, unique ID.

  An ID sequencer should be able to generate an ID and tell you the maximum value available.
  """

  @callback get_unique_id() :: integer()

  @callback max() :: integer()
end

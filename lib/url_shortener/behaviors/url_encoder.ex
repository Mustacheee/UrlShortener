defmodule UrlShortener.Behaviors.UrlEncoder do
  @moduledoc """
  This behavior describes the functions needed to be a proper URL Encoder.

  The encoder must be able to take an integer identifier and convert it to
  a binary string, used as the new slug.

  Additionally, the binary slug should be able to be decoded into the original
  integer identifier.
  """
  @callback encode(integer()) :: binary()

  @callback decode(binary()) :: integer()
end

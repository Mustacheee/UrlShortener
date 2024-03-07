defmodule UrlShortener.Behaviors.UrlEncoder do
  @moduledoc """
  This behavior describes the functions needed to be a proper URL Encoder.

  The encoder must be able to take an integer identifier and convert it to
  a binary string, used as the new slug, as well as be able to tell if a given slug
  is valid.

  Additionally, the binary slug should be able to be decoded into the original
  integer identifier.
  """

  @doc """
  Take an integer identifier and return the encoded version to be used as the short_url slug
  """
  @callback encode(integer()) :: binary()

  @doc """
  Take a slug and convert it to the corresponding identifier.
  """
  @callback decode(binary()) :: integer()

  @doc """
  Return whether or not the given string is valid and able to be decoded.
  """
  @callback is_valid?(binary()) :: boolean()
end

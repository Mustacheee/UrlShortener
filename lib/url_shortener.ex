defmodule UrlShortener do
  @moduledoc """
  UrlShortener keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias UrlShortener.Urls.Encoder58
  alias UrlShortener.Urls.FourByteIdSequencer

  def get_id_sequencer do
    Application.get_env(:url_shortener, :short_url_id_sequencer, FourByteIdSequencer)
  end

  def get_url_encoder do
    Application.get_env(:url_shortener, :url_encoder, Encoder58)
  end
end

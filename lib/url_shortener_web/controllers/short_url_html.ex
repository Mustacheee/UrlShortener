defmodule UrlShortenerWeb.ShortUrlHTML do
  use UrlShortenerWeb, :html

  embed_templates "short_url_html/*"

  @doc """
  Renders a short_url form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def short_url_form(assigns)
end

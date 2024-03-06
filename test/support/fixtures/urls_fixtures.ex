defmodule UrlShortener.UrlsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UrlShortener.Urls` context.
  """
  alias Faker.Internet
  alias Faker.UUID

  @doc """
  Generate a short_url.
  """
  def short_url_fixture(attrs \\ %{}) do
    {:ok, short_url} =
      attrs
      |> Enum.into(%{
        expires_at: ~U[2024-03-04 03:00:00Z],
        long_url: "https://#{Internet.domain_name()}/#{UUID.v4()}",
        usage_count: 0
      })
      |> UrlShortener.Urls.create_short_url()

    short_url
  end
end

defmodule UrlShortener.Urls.ShortUrl do
  @moduledoc """
  This is the DB representation for a given URL and its corresponding shortened version.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @valid_schemes ~w(http https)

  schema "short_urls" do
    field :long_url, :string
    field :slug, :string
    field :unique_id, :integer
    field :usage_count, :integer, default: 0
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(short_url, attrs) do
    short_url
    |> cast(attrs, [:long_url, :slug, :expires_at, :usage_count])
    |> validate_required([:long_url])
    |> ensure_expires_at()
    |> validate_long_url()
  end

  defp decode_slug(%Ecto.Changeset{} = changeset) do
    slug = get_change(changeset, :slug)
    encoder = UrlShortener.get_url_encoder()

    # Check to see if this is a valid slug before decoding
    case encoder.is_valid?(slug) do
      true ->
        unique_id = encoder.decode(slug)
        put_change(changeset, :unique_id, unique_id)

      false ->
        add_error(
          changeset,
          :slug,
          "Invalid characters found"
        )
    end
  end

  defp ensure_expires_at(%Ecto.Changeset{} = changeset) do
    case get_field(changeset, :expires_at) do
      nil ->
        now = Timex.now()

        expires_at =
          now
          |> Timex.shift(years: 1)
          |> Timex.to_datetime()
          |> DateTime.truncate(:second)

        put_change(changeset, :expires_at, expires_at)

      _ ->
        changeset
    end
  end

  defp ensure_slug(%Ecto.Changeset{} = changeset) do
    # Check to see if we are manually setting the slug
    case get_field(changeset, :slug) do
      slug when is_binary(slug) ->
        # If we are, then we don't need to generate one
        changeset

      _ ->
        # Generate the slug for the Unique ID we've ensured is to exist
        unique_id = get_field(changeset, :unique_id)
        encoder = UrlShortener.get_url_encoder()
        slug = encoder.encode(unique_id)
        put_change(changeset, :slug, slug)
    end
  end

  defp ensure_unique_id(%Ecto.Changeset{} = changeset) do
    # Check to see if a unique_id has already been assigned
    case get_field(changeset, :unique_id) do
      unique_id when is_number(unique_id) ->
        # If it has, then we can carry on
        changeset

      _ ->
        # If we haven't, generate one
        sequencer = UrlShortener.get_id_sequencer()
        unique_id = sequencer.get_unique_id()
        put_change(changeset, :unique_id, unique_id)
    end
  end

  defp maybe_sync_id_to_slug(%Ecto.Changeset{} = changeset) do
    # Check to see if we're setting the slug manually
    case get_change(changeset, :slug) do
      nil ->
        changeset

      slug when is_binary(slug) ->
        # If we are, decode the slug and set the corresponding ID
        decode_slug(changeset)
    end
  end

  defp validate_long_url(%Ecto.Changeset{} = changeset) do
    # Only validate if we have a URL to convert
    with long_url when is_binary(long_url) <- get_field(changeset, :long_url),
         %URI{scheme: scheme, host: host}
         when not is_nil(host) and scheme in @valid_schemes <- URI.parse(long_url) do
      changeset
      |> maybe_sync_id_to_slug()
      |> ensure_unique_id()
      |> ensure_slug()
      |> unique_constraint(:unique_id)
    else
      nil -> changeset
      _ -> add_error(changeset, :long_url, "Invalid URL, please check spelling and try again.")
    end
  end
end

defmodule UrlShortener.Repo.Migrations.CreateShortUrls do
  use Ecto.Migration

  def change do
    create table(:short_urls) do
      add :long_url, :string
      add :slug, :string
      add :unique_id, :integer
      add :usage_count, :integer
      add :expires_at, :utc_datetime
      timestamps(type: :utc_datetime)
    end

    create index(:short_urls, :long_url)
    create index(:short_urls, :slug)
    create unique_index(:short_urls, :unique_id)
  end
end

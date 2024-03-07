defmodule UrlShortenerWeb.ShortUrlController do
  use UrlShortenerWeb, :controller

  alias UrlShortener.Urls
  alias UrlShortener.Urls.ShortUrl

  require Logger

  def index(conn, _params) do
    Logger.info("Fetching short_urls for index")

    short_urls = Urls.list_short_urls()
    render(conn, :index, short_urls: short_urls)
  end

  def new(conn, _params) do
    changeset = Urls.change_short_url(%ShortUrl{})
    render(conn, :new, changeset: changeset)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"short_url" => short_url_params}) do
    Logger.info("Attempting to create short_url: #{inspect(short_url_params)}")

    case Urls.create_short_url(short_url_params) do
      {:ok, short_url} ->
        Logger.info("Short url created successfully! #{short_url.id}")

        conn
        |> put_flash(:info, "Short url created successfully.")
        |> redirect(to: ~p"/short_urls/#{short_url}")

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Failed to create short_url: #{inspect(changeset)}")
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    Logger.info("Showing Short Url #{id}")

    short_url = Urls.get_short_url!(id)
    render(conn, :show, short_url: short_url)
  end

  def edit(conn, %{"id" => id}) do
    Logger.info("Editing Short Url #{id}")

    short_url = Urls.get_short_url!(id)
    changeset = Urls.change_short_url(short_url)
    render(conn, :edit, short_url: short_url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "short_url" => short_url_params}) do
    Logger.info("Attempting to update Short Url #{id} - #{inspect(short_url_params)}")
    short_url = Urls.get_short_url!(id)

    case Urls.update_short_url(short_url, short_url_params) do
      {:ok, short_url} ->
        Logger.info("Successfully updated Short Url #{id}")

        conn
        |> put_flash(:info, "Short url updated successfully.")
        |> redirect(to: ~p"/short_urls/#{short_url}")

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Failed to update Short Url #{id}: #{inspect(changeset)}")

        render(conn, :edit, short_url: short_url, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    Logger.info("Deleting Short Url #{id}")

    short_url = Urls.get_short_url!(id)
    {:ok, _short_url} = Urls.delete_short_url(short_url)

    conn
    |> put_flash(:info, "Short url deleted successfully.")
    |> redirect(to: ~p"/short_urls")
  end

  def convert_short_slug(conn, %{"slug" => slug}) do
    Logger.info("Converting slug #{slug}")

    with short_url when not is_nil(short_url) <- Urls.get_short_url_by_slug(slug),
         false <- Urls.is_expired?(short_url) do
      Logger.info("Valid URL found! Redirecting to #{short_url.long_url}")

      Urls.increment_usage(short_url)
      redirect(conn, external: short_url.long_url)
    else
      _ ->
        Logger.error("No valid URL found for #{slug}")

        conn
        |> put_flash(:error, "Invalid or expired URL. Please check spelling and try again.")
        |> redirect(to: ~p"/")
    end
  end

  def export(conn, _params) do
    Logger.info("Exporting Short Url data to CSV")
    short_urls = Urls.list_short_urls()
    dir = System.tmp_dir!()
    timestamp = DateTime.to_unix(DateTime.utc_now())
    filename = Path.join(dir, "#{timestamp}_url_export.csv")
    file = File.open!(filename, [:write, :utf8])

    short_urls
    |> Stream.map(&Urls.to_csv_row/1)
    |> CSV.encode()
    |> Enum.each(&IO.write(file, &1))

    conn =
      conn
      |> put_flash(:info, "Download beginning shortly")
      |> send_download({:file, filename})

    spawn(File, :rm, [filename])
    halt(conn)
  end
end

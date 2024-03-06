defmodule UrlShortenerWeb.ShortUrlControllerTest do
  use UrlShortenerWeb.ConnCase

  import UrlShortener.UrlsFixtures
  alias UrlShortener.Urls

  @create_attrs %{long_url: "https://localhost.com"}
  @update_attrs %{
    long_url: "https://some.url.com",
    expires_at: ~U[2024-03-05 03:00:00Z]
  }
  @invalid_attrs %{long_url: nil, usage_count: nil, expires_at: nil}

  describe "index" do
    test "lists all short_urls", %{conn: conn} do
      conn = get(conn, ~p"/short_urls")
      assert html_response(conn, 200) =~ "Listing Short urls"
    end
  end

  describe "new short_url" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/short_urls/new")
      assert html_response(conn, 200) =~ "Create Short URL"
    end

    test "renders form on homepage", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200) =~ "Create Short URL"
    end
  end

  describe "create short_url" do
    test "redirects to show when data is valid", %{conn: conn} do
      unique_id = Enum.random(100..200)
      expect(UniqueIdSequencerMock, :get_unique_id, fn -> unique_id end)
      expect(UrlEncoderMock, :encode, fn ^unique_id -> Faker.Beer.brand() end)

      conn = post(conn, ~p"/short_urls", short_url: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/short_urls/#{id}"

      conn = get(conn, ~p"/short_urls/#{id}")
      assert html_response(conn, 200) =~ "Shortened url for #{@create_attrs.long_url}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      expect(UniqueIdSequencerMock, :get_unique_id, fn -> Enum.random(100..200) end)

      conn = post(conn, ~p"/short_urls", short_url: @invalid_attrs)
      assert html_response(conn, 200) =~ "Create Short URL"
    end
  end

  describe "edit short_url" do
    setup [:create_short_url]

    test "renders form for editing chosen short_url", %{conn: conn, short_url: short_url} do
      conn = get(conn, ~p"/short_urls/#{short_url}/edit")
      assert html_response(conn, 200) =~ "Edit Short url"
    end
  end

  describe "update short_url" do
    setup [:create_short_url]

    test "redirects when data is valid", %{conn: conn, short_url: short_url} do
      conn = put(conn, ~p"/short_urls/#{short_url}", short_url: @update_attrs)
      assert redirected_to(conn) == ~p"/short_urls/#{short_url}"

      conn = get(conn, ~p"/short_urls/#{short_url}")
      assert html_response(conn, 200) =~ @update_attrs.long_url
    end

    test "renders errors when data is invalid", %{conn: conn, short_url: short_url} do
      conn = put(conn, ~p"/short_urls/#{short_url}", short_url: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Short url"
    end
  end

  describe "delete short_url" do
    setup [:create_short_url]

    test "deletes chosen short_url", %{conn: conn, short_url: short_url} do
      conn = delete(conn, ~p"/short_urls/#{short_url}")
      assert redirected_to(conn) == ~p"/short_urls"

      assert_error_sent 404, fn ->
        get(conn, ~p"/short_urls/#{short_url}")
      end
    end
  end

  describe "convert short slug to original url" do
    setup [:create_short_url]

    test "existing slug redirects to expected url", %{conn: conn, short_url: short_url} do
      conn = get(conn, ~p"/s/#{short_url.slug}")
      assert redirected_to(conn) == short_url.long_url
    end

    test "non-existent slug redirects to home page", %{conn: conn} do
      conn = get(conn, ~p"/s/slug")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "export data to csv" do
    test "file is downloaded and the expected values are in the payload", %{conn: conn} do
      %{short_url: short_url1} = create_short_url()
      %{short_url: short_url2} = create_short_url()

      conn = get(conn, ~p"/export")

      # Verify we receieved an attachment
      [attachment] = get_resp_header(conn, "content-disposition")
      assert attachment =~ "export.csv"

      resp_body = response(conn, 200)

      # Verify the bits of data we're interested in are in the response body
      for short_url <- [short_url1, short_url2] do
        csv_string = short_url |> Urls.to_csv_row() |> Enum.join(",")
        assert resp_body =~ csv_string
      end
    end
  end

  describe "stats page" do
    test "empty state shows when no shortened urls exist", %{conn: conn} do
      conn = get(conn, ~p"/stats")

      assert response(conn, 200) =~ "No Shortened URLS"
    end

    test "existing urls show up as expected", %{conn: conn} do
      %{short_url: short_url} = create_short_url()
      conn = get(conn, ~p"/stats")

      response = response(conn, 200)

      assert response =~ short_url.long_url
      assert response =~ short_url.slug
    end
  end

  defp create_short_url(_p \\ %{}) do
    unique_id = Enum.random(100..200)
    expect(UniqueIdSequencerMock, :get_unique_id, fn -> unique_id end)
    expect(UrlEncoderMock, :encode, fn ^unique_id -> Faker.Beer.brand() end)

    short_url = short_url_fixture()
    %{short_url: short_url}
  end
end

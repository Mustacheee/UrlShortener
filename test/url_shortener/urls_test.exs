defmodule UrlShortener.UrlsTest do
  use UrlShortener.DataCase

  alias UrlShortener.Urls

  describe "short_urls" do
    alias UrlShortener.Urls.ShortUrl

    import UrlShortener.UrlsFixtures

    @invalid_attrs %{long_url: nil, usage_count: nil, expires_at: nil}

    test "list_short_urls/0 returns all short_urls" do
      short_url = create_short_url()
      assert Urls.list_short_urls() == [short_url]
    end

    test "get_short_url!/1 returns the short_url with given id" do
      short_url = create_short_url()
      assert Urls.get_short_url!(short_url.id) == short_url
    end

    test "create_short_url/1 with valid data creates a short_url" do
      unique_id = Enum.random(100..200)
      expect(UniqueIdSequencerMock, :get_unique_id, fn -> unique_id end)
      expect(UrlEncoderMock, :encode, fn ^unique_id -> Faker.Beer.brand() end)

      valid_attrs = %{
        long_url: "http://example.com",
        usage_count: 42,
        expires_at: ~U[2024-03-04 03:00:00Z]
      }

      assert {:ok, %ShortUrl{} = short_url} = Urls.create_short_url(valid_attrs)
      assert short_url.long_url == "http://example.com"
      refute is_nil(short_url.slug)
      assert short_url.usage_count == 42
      assert short_url.unique_id == unique_id
      assert short_url.expires_at == ~U[2024-03-04 03:00:00Z]
    end

    test "create_short_url/1 with invalid long_url returns error chanegset" do
      for url <- ["exa", "example.", "example.com", "htp.example.com", "http:example.com"] do
        assert {:error, %Ecto.Changeset{}} =
                 Urls.create_short_url(%{long_url: url, unique_id: 2_000})
      end
    end

    test "create_short_url/1 with valid long_url is successful" do
      for url <- [
            "http://example.com",
            "https://example.com",
            "http://www.example.com",
            "https://www.example.com",
            "http://www.example.com?one=1&two=2",
            "https://www.example.com/1/a/abc?d=1"
          ] do
        unique_id = Enum.random(100..200)
        expect(UniqueIdSequencerMock, :get_unique_id, fn -> unique_id end)
        expect(UrlEncoderMock, :encode, fn ^unique_id -> Faker.Beer.brand() end)

        assert {:ok, %ShortUrl{} = short_url} = Urls.create_short_url(%{long_url: url})

        assert short_url.long_url == url
        assert short_url.unique_id == unique_id
      end
    end

    test "create_short_url/1 with invalid data returns error changeset" do
      expect(UniqueIdSequencerMock, :get_unique_id, fn -> 100 end)
      assert {:error, %Ecto.Changeset{}} = Urls.create_short_url(@invalid_attrs)
    end

    test "update_short_url/2 updating original url and expiration works as expected" do
      short_url =
        create_short_url(%{
          long_url: "https://www.McTest.com",
          expires_at: ~U[2024-03-01 03:00:00Z]
        })

      update_attrs = %{
        long_url: "https://another.url.com",
        expires_at: ~U[2024-03-05 03:00:00Z]
      }

      assert {:ok, %ShortUrl{} = updated_short} = Urls.update_short_url(short_url, update_attrs)
      assert updated_short.long_url == "https://another.url.com"
      assert updated_short.expires_at == ~U[2024-03-05 03:00:00Z]

      # We don't expect the slug or unique id to have changed
      assert updated_short.slug == short_url.slug
      assert updated_short.unique_id == short_url.unique_id
    end

    test "update_short_url/2 updating the slug changes unique_id as expected" do
      # Set up original id and slug to go with it
      original_id = 101
      expect(UniqueIdSequencerMock, :get_unique_id, fn -> original_id end)
      expect(UrlEncoderMock, :encode, fn ^original_id -> "testSlug" end)
      short_url = short_url_fixture()

      # Generate a new id and update to a custom slug
      unique_id = :rand.uniform(100)
      update_attrs = %{slug: "custom"}
      # Se the custom slug to map back to our new id
      expect(UrlEncoderMock, :decode, fn "custom" -> unique_id end)

      assert {:ok, %ShortUrl{} = updated_short} = Urls.update_short_url(short_url, update_attrs)

      # Slug and decoded id should match what we expect them to be
      assert updated_short.slug == "custom"
      assert updated_short.unique_id == unique_id
    end

    test "update_short_url/2 with invalid data returns error changeset" do
      short_url = create_short_url()
      assert {:error, %Ecto.Changeset{}} = Urls.update_short_url(short_url, @invalid_attrs)
      assert short_url == Urls.get_short_url!(short_url.id)
    end

    test "delete_short_url/1 deletes the short_url" do
      short_url = create_short_url()
      assert {:ok, %ShortUrl{}} = Urls.delete_short_url(short_url)
      assert_raise Ecto.NoResultsError, fn -> Urls.get_short_url!(short_url.id) end
    end

    test "change_short_url/1 returns a short_url changeset" do
      short_url = create_short_url()
      assert %Ecto.Changeset{} = Urls.change_short_url(short_url)
    end

    test "increment_usage/1 usage count is updated as expected" do
      start_count = :rand.uniform(100)
      # Create URL that we want to increment
      short_url = create_short_url(%{usage_count: start_count})
      # And one that we want to double check DOESN'T get incremented
      other_url = create_short_url(%{usage_count: start_count})

      # Make sure initial data is what we think it should be
      assert short_url.usage_count == start_count
      assert other_url.usage_count == start_count

      # Only one record should be updated
      assert {1, _} = Urls.increment_usage(short_url)

      # Get latest DB values for our records
      short_url = Repo.get!(ShortUrl, short_url.id)
      other_url = Repo.get!(ShortUrl, other_url.id)

      # short_url should have been incremented
      assert short_url.usage_count == start_count + 1
      # The dummy URL should not have been incremented
      assert other_url.usage_count == start_count
    end

    test "get_short_url_by_slug/1 returns the expected short_url record" do
      unique_id = Enum.random(100..200)
      expect(UrlEncoderMock, :decode, fn "abc" -> unique_id end)

      short_url = short_url_fixture(%{slug: "abc"})
      response = Urls.get_short_url_by_slug(short_url.slug)

      assert short_url.id == response.id
    end

    test "get_short_url_by_slug/1 for unknown slug is nil" do
      response = Urls.get_short_url_by_slug("random slug")
      assert is_nil(response)
    end

    defp create_short_url(params \\ %{}) do
      unique_id = Enum.random(100..200)
      expect(UniqueIdSequencerMock, :get_unique_id, fn -> unique_id end)
      expect(UrlEncoderMock, :encode, fn ^unique_id -> Faker.Beer.brand() end)

      short_url_fixture(params)
    end
  end
end

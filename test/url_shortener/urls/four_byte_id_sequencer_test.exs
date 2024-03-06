defmodule UrlShortener.Urls.FourByteIdSequencerTest do
  use UrlShortener.DataCase
  alias UrlShortener.Urls.FourByteIdSequencer

  describe "get_unique_id/1" do
    max = FourByteIdSequencer.max()
    count = Enum.random(50..100)

    ids =
      1..count
      |> Enum.map(fn _ ->
        id = FourByteIdSequencer.get_unique_id()
        assert id <= max
        id
      end)
      |> Enum.dedup()

    # After deduplication, list should be full size
    assert length(ids) == count
  end
end

defmodule UrlShortener.Urls.Encoder58Test do
  use UrlShortener.DataCase
  alias UrlShortener.Urls.Encoder58

  @test_pairs [
    {500, "8c"},
    {1_000_000, "57FN"},
    {100_000, "Vi8"},
    {20, "L"},
    {200, "3S"},
    {2_000_000, "AEWk"}
  ]

  describe "encode/1" do
    test "a number below 58 should be one character" do
      value = Enum.random(1..58)
      encoded = Encoder58.encode(value)
      assert String.length(encoded) == 1
    end

    test "a number above 58 should be two characters" do
      value = Enum.random(59..115)
      encoded = Encoder58.encode(value)
      assert String.length(encoded) == 2
    end

    test "converting the test pairs results in the expected value" do
      Enum.each(@test_pairs, fn {input, expected} ->
        encoded = Encoder58.encode(input)
        assert encoded == expected
      end)
    end

    test "encoding then decoding results in the original value" do
      value = Enum.random(100..1_000)
      processed = value |> Encoder58.encode() |> Encoder58.decode()
      assert processed == value
    end
  end

  describe "decode/2" do
    test "decoding a single digit input should also result in a digit" do
      Enum.each(1..9, fn digit ->
        decoded = Encoder58.decode("#{digit}")
        assert decoded == digit
      end)
    end

    test "decoding the test pairs results in the expected value" do
      Enum.each(@test_pairs, fn {expected, input} ->
        encoded = Encoder58.decode(input)
        assert encoded == expected
      end)
    end

    test "decoding then encoding results in the original value" do
      chars = ~w(A B C D E F G H J K L M N P Q R S T U V W X Y Z)
      length = Enum.random(1..5)
      value = Enum.map_join(1..length, fn _ -> Enum.random(chars) end)

      processed =
        value
        |> Encoder58.decode()
        |> Encoder58.encode()

      assert processed == value
    end
  end
end

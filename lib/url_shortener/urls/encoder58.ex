defmodule UrlShortener.Urls.Encoder58 do
  @moduledoc """
  This module is a base-58 URL encoder. We start with all alpha-numeric
  characters, then remove 0, O, I, l for readability purposes as they
  look similar and can be confused with one another.
  """
  @behaviour UrlShortener.Behaviors.UrlEncoder

  @valid_nums ~w(1 2 3 4 5 6 7 8 9)
  @valid_upper ~w(A B C D E F G H J K L M N P Q R S T U V W X Y Z)
  @valid_lower ~w(a b c d e f g h i j k m n o p q r s t u v w x y z)

  # The maximum digits it would take to convert a 64-bit integer into base-58
  @max_length 11

  # Combine our sequence with numbers first, upper alpha, then lower alpha
  @sequence @valid_nums ++ @valid_upper ++ @valid_lower
  @sequence_length length(@sequence)

  @impl true
  @spec encode(number()) :: binary()
  def encode(identifier) when is_number(identifier) do
    Enum.reduce_while(1..@max_length, {identifier, []}, fn
      _, {0, chars} ->
        {:halt, chars}

      _, {leftover, chars} ->
        # Reduce by 1 to take into account 0-indexing
        leftover = leftover - 1
        sequence_pos = rem(leftover, @sequence_length)
        sequence_char = Enum.at(@sequence, sequence_pos)
        leftover = div(leftover, @sequence_length)

        {:cont, {leftover, [sequence_char | chars]}}
    end)
    |> Enum.join("")
  end

  @impl true
  def decode(slug) when is_binary(slug) do
    split_url = String.split(slug, "", trim: true)

    url_length = length(split_url)

    split_url
    |> Enum.with_index()
    |> Enum.reduce(0, fn {char, position}, acc ->
      power = url_length - position - 1
      # Add one to go from 0 to 1-indexing
      sequence_pos = Enum.find_index(@sequence, &(&1 == char)) + 1
      value = sequence_pos * @sequence_length ** power
      acc + value
    end)
  end

  @impl true
  def is_valid?(value) when is_binary(value) do
    value
    |> String.split("", trim: true)
    # Check if any characters are not in our sequence
    |> Enum.all?(&Enum.member?(@sequence, &1))
  end
end

defmodule PasswordGenerator do
  @moduledoc """
  Generates random password depanding on paramenters provided.
  module's main function is generate(options), it takes in a map of options and returns a string
  """

  @allowed_options [:length, :numbers, :uppercase, :symbols]

  @doc """
  Generates password according to a given option
  ## Examples
    options %{
      "length" => "5",
      "numbers" => "false",
      "uppercase" => "false",
      "symbols" => "false"
    }

      iex> PasswordGenerator.generate(options)
      "abcde"
  """
  @spec generate(options :: map()) :: {:okay, bitstring()} | {:error, bitstring()}
  def generate(options) do
    length = Map.has_key?(options, "length")
    validate_length(length, options)
  end

  defp validate_length(false, _options), do: {:error, "Please provide a length."}

  defp validate_length(true, options) do
    length = options["length"]
    numbers = Enum.map(0..9, &Integer.to_string(&1))
    length = String.contains?(length, numbers)
    validate_length_is_integer(length, options)
  end

  defp validate_length_is_integer(false, _options), do: {:error, "length must be an integer"}

  defp validate_length_is_integer(true, options) do
    length = options["length"] |> String.trim() |> String.to_integer()
    options_without_length = Map.delete(options, "length")
    options_values = Map.values(options_without_length)
    values = options_values |> Enum.all?(fn x -> String.to_atom(x) |> is_boolean() end)
    validate_option_values_are_bolean(values, length, options_without_length)
  end

  defp validate_option_values_are_bolean(false, _length, _options),
    do: {:error, "all options except length must be boolean"}

  defp validate_option_values_are_bolean(true, length, options) do
    options = included_options(options)
    invalid_options? = options |> Enum.any?(&(&1 not in @allowed_options))
    validate_options(invalid_options?, length, options)
  end

  defp included_options(options) do
    Enum.filter(options, fn {_key, value} ->
      value |> String.trim() |> String.to_existing_atom()
    end)
    |> Enum.map(fn {key, _value} -> String.to_atom(key) end)
  end

  defp validate_options(true, _length, _options),
    do: {:error, "only length numbers, uppercase and symbols are allow options"}

  defp validate_options(false, length, options) do
    generate_strings(length, options)
  end

  defp generate_strings(length, options) do
    options = [:lowercase_letters | options]
    included = include(options)
    length = length - length(included)
    random_strings = generate_random_strings(length, options)
    strings = included ++ random_strings
    get_result(strings)
  end

  defp include(options) do
    options
    |> Enum.map(&get(&1))
  end

  defp get(:lowercase_letters) do
    <<Enum.random(?a..?z)>>
  end

  defp get(:uppercase) do
    <<Enum.random(?A..?Z)>>
  end

  defp get(:numbers) do
    <<Enum.random(?0..?9)>>
  end

  defp get(:symbols) do
    String.split("!@#$%^&*()_+;:'\|[{]},.<>/?", "", trim: true) |> Enum.random()
  end

  defp generate_random_strings(length, options) do
    Enum.map(1..length, fn _ ->
      Enum.random(options) |> get()
    end)
  end

  defp get_result(strings) do
    string =
      strings
      |> Enum.shuffle()
      |> to_string()

    {:okay, string}
  end
end

defmodule PasswordGen do
  @allowed_options [:length, :numbers, :uppercase, :symbols]

  @spec generate(options :: map()) :: {:okay, bitstring()} | {:error, bitstring()}

  def generate(options) do
    hasLength = Map.has_key?(options, "length")

    unless hasLength do
      {:error, "You need to provide the length of the password"}
    else
      lengthIsInt = checkLengthIsInt(options)

      unless lengthIsInt do
        {:error, "Length should be an interger"}
      else
        length = options["length"] |> String.trim() |> String.to_integer()

        unless length >= 5 do
          {:error, "Length should be greater than or equal to 5"}
        else
          options_without_length = Map.delete(options, "length")
          options_values = Map.values(options_without_length)

          allIsBoolean =
            options_values |> Enum.all?(fn x -> String.to_atom(x) |> is_boolean() end)

          unless allIsBoolean do
            {:error, "all options except length must be boolean"}
          else
            options = included_options(options_without_length)
            invalidOptionIsIncluded = options |> Enum.any?(&(&1 not in @allowed_options))

            if invalidOptionIsIncluded do
              {:error, "only length numbers, uppercase and symbols are allow options"}
            else
              generated_password = generate_strings(length, options)
              {:okay, generated_password}
            end
          end
        end
      end
    end
  end

  defp checkLengthIsInt(options) do
    length = options["length"]
    numbers = Enum.map(0..9, &Integer.to_string(&1))
    String.contains?(length, numbers)
  end

  defp generate_strings(length, options) do
    options = [:lowercase_letters | options]
    all_options_char = include_all_options_char(options)
    length = length - length(all_options_char)
    random_strings = generate_random_strings(length, options)
    password_string = all_options_char ++ random_strings
    randomize_string(password_string)
  end

  defp included_options(options) do
    Enum.filter(options, fn {_key, value} ->
      value |> String.trim() |> String.to_existing_atom()
    end)
    |> Enum.map(fn {key, _value} -> String.to_atom(key) end)
  end

  defp include_all_options_char(options) do
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

  defp randomize_string(strings) do
    strings
    |> Enum.shuffle()
    |> to_string()
  end
end

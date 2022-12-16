defmodule PasswordGenTest do
  use ExUnit.Case

  setup do
    options = %{
      "length" => "10",
      "numbers" => "false",
      "uppercase" => "false",
      "symbols" => "false"
    }

    options_types = %{
      lowercase: Enum.map(?a..?z, &<<&1>>),
      numbers: Enum.map(0..9, &Integer.to_string(&1)),
      uppercase: Enum.map(?A..?Z, &<<&1>>),
      symbols: String.split("!@#$%^&*()_+;:'\|[{]},.<>/?", "", trim: true)
    }

    {:okay, result} = PasswordGen.generate(options)

    %{
      options_types: options_types,
      result: result
    }
  end

  test "returns a string", %{result: result} do
    assert is_bitstring(result)
  end

  test "returns error when no length is given" do
    options = %{"invalid" => "false"}
    {:error, _error} = PasswordGen.generate(options)
  end

  test "returns error when length is not an integer" do
    options = %{"length" => "abcf"}
    assert {:error, _error} = PasswordGen.generate(options)
  end

  test "length of returned string is the option provided" do
    length_option = %{"length" => "10"}
    {:okay, result} = PasswordGen.generate(length_option)
    assert 10 = String.length(result)
  end

  test "returns a lowercase string just with the lenght", %{options_types: options} do
    length_option = %{"length" => "8"}
    {:okay, result} = PasswordGen.generate(length_option)
    assert String.contains?(result, options.lowercase)
    refute String.contains?(result, options.numbers)
    refute String.contains?(result, options.uppercase)
    refute String.contains?(result, options.symbols)
  end

  test "returns error when options values (except length) are not bolean" do
    options = %{
      "length" => "10",
      "numbers" => "invalid",
      "uppercase" => "324",
      "symbols" => "yet another invalid"
    }

    assert {:error, _error} = PasswordGen.generate(options)
  end

  test "returns error when option not allowed" do
    options = %{
      "length" => "5",
      "strange_option" => "not allowed"
    }

    assert {:error, _error} = PasswordGen.generate(options)
  end

  test "returns error when 1 option not allowed" do
    options = %{"length" => "10", "numbers" => "true", "invalid" => "true"}
    assert {:error, _error} = PasswordGen.generate(options)
  end

  test "returns string uppercase", %{options_types: options} do
    uppercaseOptions = %{
      "length" => "5",
      "numbers" => "false",
      "uppercase" => "true",
      "symbols" => "false"
    }

    {:okay, result} = PasswordGen.generate(uppercaseOptions)

    assert String.contains?(result, options.uppercase)

    refute String.contains?(result, options.numbers)
    refute String.contains?(result, options.symbols)
  end

  test "returns string with numbers", %{options_types: options} do
    numberOptions = %{
      "length" => "10",
      "numbers" => "true",
      "uppercase" => "false",
      "symbols" => "false"
    }

    {:okay, result} = PasswordGen.generate(numberOptions)

    assert String.contains?(result, options.numbers)

    refute String.contains?(result, options.uppercase)
    refute String.contains?(result, options.symbols)
  end

  test "returns string with symbols", %{options_types: options} do
    numberOptions = %{
      "length" => "10",
      "numbers" => "false",
      "uppercase" => "false",
      "symbols" => "true"
    }

    {:okay, result} = PasswordGen.generate(numberOptions)

    assert String.contains?(result, options.symbols)

    refute String.contains?(result, options.uppercase)
    refute String.contains?(result, options.numbers)
  end

  test "returns string with symbols and uppercase", %{options_types: options} do
    numberOptions = %{
      "length" => "10",
      "numbers" => "false",
      "uppercase" => "true",
      "symbols" => "true"
    }

    {:okay, result} = PasswordGen.generate(numberOptions)

    assert String.contains?(result, options.symbols)
    assert String.contains?(result, options.uppercase)

    refute String.contains?(result, options.numbers)
  end

  test "returns string with symbols and numbers", %{options_types: options} do
    numberOptions = %{
      "length" => "10",
      "numbers" => "true",
      "uppercase" => "false",
      "symbols" => "true"
    }

    {:okay, result} = PasswordGen.generate(numberOptions)

    assert String.contains?(result, options.symbols)
    assert String.contains?(result, options.numbers)

    refute String.contains?(result, options.uppercase)
  end

  test "returns string with numbers and uppercase", %{options_types: options} do
    numberOptions = %{
      "length" => "10",
      "numbers" => "true",
      "uppercase" => "true",
      "symbols" => "false"
    }

    {:okay, result} = PasswordGen.generate(numberOptions)

    assert String.contains?(result, options.uppercase)
    assert String.contains?(result, options.numbers)

    refute String.contains?(result, options.symbols)
  end

  test "returns string with all options", %{options_types: options} do
    numberOptions = %{
      "length" => "10",
      "numbers" => "true",
      "uppercase" => "true",
      "symbols" => "true"
    }

    {:okay, result} = PasswordGen.generate(numberOptions)
    IO.puts(result)

    assert String.contains?(result, options.symbols)
    assert String.contains?(result, options.uppercase)
    assert String.contains?(result, options.numbers)
  end
end

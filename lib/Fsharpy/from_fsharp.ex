defmodule Fsharpy.FromFsharp do
    @moduledoc """
    Helper functions to take FSI output and convert `val` items into their
    appoxiamate Elixir equivalents.
    """
    def get_vals raw_output do
        raw_output
            |> String.replace("list =\n", "list = ")
            |> String.split("\n")
            |> Enum.filter(fn z -> String.starts_with?(z, "val ") end)
            |> Enum.map(fn z -> get_val(z) end)
    end

    def get_val line do
        [name_part | [rest]] = String.split(line, " : ", parts: 2, trim: true)
        [type_part | [value_part]] = String.split(rest, " = ", parts: 2, trim: true)

        variable_name = String.trim_leading(name_part, "val ")
        map = %{name: variable_name, type: type_part, value: value_part}
        attempt_deserializion map
    end

    defp attempt_deserializion(%{name: variable_name, type: "int", value: value_part}) do
        %{variable_name => to_int(value_part)}
    end

    defp attempt_deserializion(%{name: variable_name, type: "float", value: value_part}) do
        %{variable_name => to_float(value_part)}
    end

    defp attempt_deserializion(%{name: variable_name, type: "string", value: value_part}) do
        new_value = value_part
            |> String.replace_prefix("\"", "")
            |> String.replace_suffix("\"", "")
        %{variable_name => new_value}
    end

    defp attempt_deserializion(%{name: variable_name, type: "bool", value: value_part}) do
        new_value = case value_part do
            "true" -> true
            "false" -> false
        end
        %{variable_name => new_value}
    end

    defp attempt_deserializion(%{name: variable_name, type: "int * int", value: value_part}) do
        %{variable_name => to_tuple(value_part, &(to_int/1))}
    end

    defp attempt_deserializion(%{name: variable_name, type: "int * int * int", value: value_part}) do
        %{variable_name => to_tuple(value_part, &(to_int/1))}
    end

    defp attempt_deserializion(%{name: variable_name, type: "float * float", value: value_part}) do
        %{variable_name => to_tuple(value_part, &(to_float/1))}
    end

    defp attempt_deserializion(%{name: variable_name, type: "float * float * float", value: value_part}) do
        %{variable_name => to_tuple(value_part, &(to_float/1))}
    end

    defp attempt_deserializion(%{name: variable_name, type: "int list", value: value_part}) do
        new_value =
            value_part
            |> String.replace_prefix("[", "") |> String.replace_suffix("]", "")
            |> String.split("; ")
            |> Enum.map(fn (x) -> to_int(x) end)
        %{variable_name => new_value}
    end

    defp attempt_deserializion(map) do
        map
    end

    defp to_tuple(value_part, parser_fun) do
        elements = value_part
            |> String.trim_leading("(")
            |> String.trim_trailing(")")
            |> String.split(", ", trim: true)

        list = elements |> Enum.map(fn x -> parser_fun.(x) end)
        list |> List.to_tuple
    end

    defp to_int int_string do
        {result, _} = Integer.parse(int_string)
        result
    end

    defp to_float float_string do
        {result, _} = Float.parse(float_string)
        result
    end

end
defmodule Codeowners do
  @moduledoc """
  Documentation for `Codeowners`.
  """

  defstruct path: nil, rules: []

  defmodule Rule do
    @moduledoc """
    Documentation for `Codeowners.Rule`.
    """

    defstruct pattern: nil, regex: nil, owners: []

    def regex(pattern) do
      Regex.compile(pattern)
    end
  end

  @doc """
  Hello world.
  """
  def load(path) do
    File.read!(path)
    |> Codeowners.build()
    |> Map.put(:path, path)
  end

  def build(contents \\ "") do
    rules =
      contents
      |> String.split("\n", trim: true)
      |> Enum.reject(fn line -> String.starts_with?(line, "#") end)
      |> Enum.map(fn line ->
        [pattern | owners] = String.split(line)
        %Codeowners.Rule{pattern: pattern, regex: Rule.regex(pattern), owners: owners}
      end)

    %Codeowners{rules: rules}
  end
end

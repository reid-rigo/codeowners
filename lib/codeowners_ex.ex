defmodule CodeownersEx do
  @moduledoc """
  Documentation for `CodeownersEx`.
  """

  defstruct path: nil, rules: []

  defmodule Rule do
    @moduledoc """
    Documentation for `CodeownersEx.Rule`.
    """

    defstruct pattern: nil, regex: nil, owners: []

    def regex(pattern) do
      Regex.compile(pattern)
    end
  end

  @doc """
  Hello world.

  ## Examples

      iex> CodeownersEx.load(path)
      :world

  """
  def load(path) do
    File.read!(path) |> build(path)
  end

  def build(contents \\ "", path \\ nil) do
    rules =
      contents
      |> String.split("\n", trim: true)
      |> Enum.reject(fn line -> String.starts_with?(line, "#") end)
      |> Enum.map(fn line ->
        [pattern | owners] = String.split(line)
        %CodeownersEx.Rule{pattern: pattern, regex: Rule.regex(pattern), owners: owners}
      end)

    %CodeownersEx{path: path, rules: rules}
  end
end

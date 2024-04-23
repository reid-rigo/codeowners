defmodule Codeowners.Rule do
  @moduledoc """
  Contains types and functions related to individual CODEOWNERS rules.
  """

  alias Codeowners.Rule

  @type t :: %Codeowners.Rule{pattern: String.t(), regex: Regex.t(), owners: list(String.t())}
  defstruct pattern: nil, regex: nil, owners: []

  @doc """
  Build a `Codeowners.Rule` for the given CODEOWNERS line.
  """
  @spec regex(String.t()) :: t() | nil
  def build(line) when is_binary(line) do
    rule =
      String.split(line, "#")
      |> List.first()

    case rule do
      "" ->
        nil

      _ ->
        [pattern | owners] = String.split(rule)
        %Rule{pattern: pattern, regex: Rule.regex(pattern), owners: owners}
    end
  end

  @doc """
  Compile a `Regex` for the given pattern string.
  """
  @spec regex(String.t()) :: Regex.t()
  def regex(pattern) when is_binary(pattern) do
    replacements = %{
      "/**/" => "[^.]*/",
      "**" => ".*",
      "*" => "[^/]*",
      "/" => "\\/",
      "." => "\\."
    }

    pattern
    |> String.replace_prefix("/", "\\A/")
    |> String.replace_suffix("/*", "/*\\z")
    |> String.replace_suffix("/**", "/**\\z")
    |> String.replace(Map.keys(replacements), &Map.get(replacements, &1))
    |> Regex.compile!()
  end
end

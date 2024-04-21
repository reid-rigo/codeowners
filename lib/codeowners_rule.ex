defmodule Codeowners.Rule do
  @moduledoc """
  Contains types and functions related to individual CODEOWNERS rules.
  """

  @type t :: %Codeowners.Rule{pattern: String.t(), regex: Regex.t(), owners: list(String.t())}
  defstruct pattern: nil, regex: nil, owners: []

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

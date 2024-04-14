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
      replacements = %{
        "/**/" => "[^.]*/",
        "**" => ".*",
        "*" => "[^/]*",
        "/" => "\/",
        "." => "\."
      }

      pattern
      |> String.replace_prefix("/", "\\A/")
      |> String.replace_suffix("/*", "/*\\z")
      |> String.replace_suffix("/**", "/**\\z")
      |> String.replace(Map.keys(replacements), &Map.get(replacements, &1))
      |> Regex.compile!()
    end
  end

  @doc """
  Hello world.
  """
  def load(path) do
    File.read!(path)
    |> build()
    |> Map.put(:path, path)
  end

  def build(file_content \\ "") do
    rules =
      file_content
      |> String.split("\n", trim: true)
      |> Enum.reject(fn line -> String.starts_with?(line, "#") end)
      |> Enum.map(fn line ->
        [pattern | owners] = String.split(line)
        %Rule{pattern: pattern, regex: Rule.regex(pattern), owners: owners}
      end)

    %Codeowners{rules: rules}
  end

  def rule_for_path(%Codeowners{} = codeowners, path) do
    codeowners.rules
    |> Enum.reverse()
    |> Enum.find(
      %Rule{},
      fn rule -> Regex.match?(rule.regex, path) end
    )
  end

  def rule_for_module(%Codeowners{} = codeowners, module) do
    path = module.module_info()[:compile][:source]
    rule_for_path(codeowners, path)
  end
end

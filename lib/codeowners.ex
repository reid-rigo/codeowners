defmodule Codeowners do
  @moduledoc """
  A pure Elixir parser for the Github CODEOWNERS [specification](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners).
  """

  alias Codeowners.Rule

  @type t :: %Codeowners{path: String.t() | nil, root: String.t(), rules: list(Rule.t())}
  defstruct path: nil, root: nil, rules: []

  @doc """
  Loads a CODEOWNERS file from the given path, returning a `Codeowners` struct.

  `load/1` calls `build/1` to process the contained ownership rules.
  """
  @spec load(String.t()) :: t()
  def load(path) when is_binary(path) do
    File.read!(path)
    |> build()
    |> Map.put(:path, path)
  end

  @doc """
  Builds a `Codeowners` struct from a string containing CODEOWNERS rules.

  Parses each line generating a list of `Codeowners.Rule`.
  Stores `File.cwd/0` as `:root`.

  For most use cases it makes sense to use `load/1`, which in turn calls `build/1`
  """
  @spec build(String.t()) :: t()
  def build(file_content \\ "") when is_binary(file_content) do
    rules =
      file_content
      |> String.split("\n", trim: true)
      |> Enum.reject(fn line -> String.starts_with?(line, "#") end)
      |> Enum.map(fn line ->
        [pattern | owners] = String.split(line)
        %Rule{pattern: pattern, regex: Rule.regex(pattern), owners: owners}
      end)

    root = File.cwd!()

    %Codeowners{rules: rules, root: root}
  end

  @doc """
  Given a `Codeowners` struct and path, return the matching rule or empty rule.

  Searches in reverse to return the last match.
  Handles full paths by removing the root directory before matching.
  """
  @spec rule_for_path(t(), String.t()) :: Rule.t()
  def rule_for_path(%Codeowners{} = codeowners, path) when is_binary(path) do
    relative_path = String.replace_prefix(path, codeowners.root, "")

    codeowners.rules
    |> Enum.reverse()
    |> Enum.find(
      %Rule{},
      fn rule -> Regex.match?(rule.regex, relative_path) end
    )
  end

  @doc """
  Given a `Codeowners` struct and an Elixir module, return the matching rule or empty rule.

  `Codeowners.rule_for_module` calls `Codeowners.rule_for_path`.
  """
  @spec rule_for_module(t(), module()) :: Rule.t()
  def rule_for_module(%Codeowners{} = codeowners, module) do
    path = module.module_info()[:compile][:source] |> to_string()
    rule_for_path(codeowners, path)
  end

  defimpl Inspect, for: Codeowners do
    def inspect(codeowners, opts) do
      limit = min(opts.limit, 10)
      opts = Map.put(opts, :limit, limit)
      Inspect.Any.inspect(codeowners, opts)
    end
  end
end

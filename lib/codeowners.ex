defmodule Codeowners do
  @moduledoc """
  A pure Elixir parser for the GitHub CODEOWNERS [specification](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners).

  ```elixir
  > Codeowners.load(".github/CODEOWNERS") |> Codeowners.rule_for_path("docs/setup.md")
  %Codeowners.Rule{
    pattern: "docs/*",
    regex: ~r/docs\/[^\/]*\z/,
    owners: ["docs@example.com"]
  }
  ```
  """

  alias __MODULE__.Rule

  @type t :: %__MODULE__{path: String.t() | nil, root: String.t(), rules: list(Rule.t())}
  defstruct path: nil, root: nil, rules: []

  @doc """
  Loads a CODEOWNERS file from the given path, returning a `#{inspect(__MODULE__)}` struct.

  `load/2` calls `build/2` to process the contained ownership rules.
  """
  @spec load(String.t(), root: String.t()) :: t()
  def load(path, opts \\ []) when is_binary(path) and is_list(opts) do
    opts = Keyword.merge(opts, path: path)
    file_content = File.read!(path)
    build(file_content, opts)
  end

  @doc """
  Builds a `#{inspect(__MODULE__)}` struct from a string containing CODEOWNERS rules.

  Parses each line generating a list of `Codeowners.Rule`.

  For most use cases it makes sense to use `load/2`, which in turn calls `build/2`
  """
  @spec build(String.t(), root: String.t(), path: String.t()) :: t()
  def build(file_content \\ "", opts \\ [])
      when is_binary(file_content) and is_list(opts) do
    rules =
      file_content
      |> String.split(["\n", "\r", "\r\n"])
      |> Enum.with_index()
      |> Enum.map(fn {line, line_number} -> Rule.build(line, line_number + 1) end)
      |> Enum.reject(&is_nil/1)

    root =
      Keyword.get_lazy(opts, :root, &File.cwd!/0)
      |> String.replace_suffix("/", "")

    %__MODULE__{rules: rules, root: root, path: opts[:path]}
  end

  @doc """
  Given a `#{inspect(__MODULE__)}` struct and path, return the matching rule or empty rule.

  Searches in reverse to return the last match.
  Handles full paths by removing the root directory before matching.
  """
  @spec rule_for_path(t(), String.t()) :: Rule.t()
  def rule_for_path(%__MODULE__{} = codeowners, path) when is_binary(path) do
    relative_path = String.replace_prefix(path, codeowners.root, "")

    codeowners.rules
    |> Enum.reverse()
    |> Enum.find(
      %Rule{},
      fn rule -> Regex.match?(rule.regex, relative_path) end
    )
  end

  @doc """
  Given a `#{inspect(__MODULE__)}` struct and an Elixir module, return the matching rule or empty rule.

  `rule_for_module/2` calls `rule_for_path/2`.
  """
  @spec rule_for_module(t(), module()) :: Rule.t()
  def rule_for_module(%__MODULE__{} = codeowners, module) do
    path = module.module_info()[:compile][:source] |> to_string()
    rule_for_path(codeowners, path)
  end

  defimpl Inspect, for: __MODULE__ do
    def inspect(codeowners, opts) do
      limit = min(opts.limit, 10)
      opts = Map.put(opts, :limit, limit)
      Inspect.Any.inspect(codeowners, opts)
    end
  end
end

# Codeowners

A pure Elixir parser for the GitHub CODEOWNERS [specification](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners).

## Installation

The package can be installed by adding `codeowners` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:codeowners, "~> 0.1.6"}
  ]
end
```

## Basic usage

```elixir
> codeowners = Codeowners.load(".github/CODEOWNERS")
%Codeowners{
  path: "/Users/me/project/.github/CODEOWNERS",
  root: "/Users/me/project",
  rules: [
    %Codeowners.Rule{
      pattern: "*",
      regex: ~r/[^\/]*/,
      owners: ["@global-owner1", "@global-owner2"]
    },
    %Codeowners.Rule{
      pattern: "*.js",
      regex: ~r/[^\/]*\.js/,
      owners: ["@js-owner"]
    },
    ...
  ]
}

> matching_rule = Codeowners.rule_for_path(codeowners, "docs/setup.md")
%Codeowners.Rule{
  pattern: "docs/*",
  regex: ~r/docs\/[^\/]*\z/,
  owners: ["docs@example.com"]
}
```

## License

MIT License - see the [LICENSE](https://github.com/reid-rigo/codeowners/blob/main/LICENSE) file.

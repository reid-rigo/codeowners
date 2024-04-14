# Codeowners

A pure Elixir CODEOWNERS parser.

## Installation

The package can be installed by adding `codeowners` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:codeowners, "~> 0.1.0"}
  ]
end
```

## Basic usage

```elixir
codeowners = Codeowners.load(Path.expand("./.github/CODEOWNERS"))
matching_rule = Codeowners.rule_for_path(codeowners, "lib/my_module.ex")
```

## License

MIT License - see the [LICENSE](https://github.com/reid-rigo/codeowners/blob/main/LICENSE) file.

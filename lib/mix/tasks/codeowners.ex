defmodule Mix.Tasks.Codeowners do
  @moduledoc """
  List owners for files based on CODEOWNERS.

      mix codeowners lib/
  """
  @shortdoc "List owners for files based on CODEOWNERS"

  use Mix.Task

  @impl Mix.Task
  def run([]) do
    warning = IO.ANSI.format([:red, "No files or directories provided\n"])
    IO.puts(warning)

    usage = [
      "Example:\n\t",
      IO.ANSI.format([:bright, "mix codeowners lib/"])
    ]

    IO.puts(Enum.join(usage))
  end

  def run(args) do
    codeowners = Codeowners.load(codeowners_path())
    IO.puts(IO.ANSI.format([:green, "Using " <> codeowners.path]))

    summary =
      relative_paths_from_args(args)
      |> Enum.map(fn path ->
        [path, Codeowners.rule_for_path(codeowners, "/" <> path).owners]
      end)
      |> output_lines()
      |> Enum.join("\r\n")

    IO.puts(summary)
  end

  # convert list of pairs to strings for output
  defp output_lines(results) do
    width =
      results
      |> Enum.map(fn [path, _] -> String.length(path) end)
      |> Enum.max(&>/2, fn -> 0 end)
      |> then(fn n -> n + 4 end)

    Enum.map(results, fn [path, owners] ->
      padded_path = String.pad_trailing(path, width)

      owners_string =
        case owners do
          [] -> IO.ANSI.format([:faint, "No one"])
          _ -> IO.ANSI.format([:blue, Enum.join(owners, " ")])
        end
        |> IO.chardata_to_string()

      padded_path <> owners_string
    end)
  end

  defp relative_paths_from_args(["."]), do: relative_paths_from_args(["*"])

  # convert args to a list of relative paths to be checked
  defp relative_paths_from_args(args) do
    Enum.flat_map(args, fn arg ->
      Path.wildcard(arg)
    end)
    |> Enum.sort()
  end

  # for convenience, find CODEOWNERS following GitHub's allowed locations
  defp codeowners_path() do
    Enum.find(
      ~w(.github/CODEOWNERS CODEOWNERS docs/CODEOWNERS),
      &File.exists?/1
    )
  end
end

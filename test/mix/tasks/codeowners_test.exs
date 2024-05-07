defmodule Mix.Tasks.CodeownersTest do
  @moduledoc false

  use ExUnit.Case

  describe "run" do
    test "prints detected CODEOWNERS" do
      output =
        ExUnit.CaptureIO.capture_io(fn ->
          Mix.Tasks.Codeowners.run(["README.md"])
        end)

      assert String.contains?(output, "Using .github/CODEOWNERS")
    end

    test "prints owners" do
      output =
        ExUnit.CaptureIO.capture_io(fn ->
          Mix.Tasks.Codeowners.run(["README.md"])
        end)

      last_line =
        output
        |> String.split("\n", trim: true)
        |> List.last()

      assert String.contains?(last_line, "README.md")
    end

    test "prints a warning message" do
      output =
        ExUnit.CaptureIO.capture_io(fn ->
          Mix.Tasks.Codeowners.run([])
        end)

      assert String.contains?(output, "No files or directories provided")
    end

    test "prints a usage message" do
      output =
        ExUnit.CaptureIO.capture_io(fn ->
          Mix.Tasks.Codeowners.run([])
        end)

      assert String.contains?(output, "Example:")
      assert String.contains?(output, "mix codeowners lib/")
    end
  end
end

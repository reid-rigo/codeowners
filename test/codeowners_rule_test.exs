defmodule CodeownersRuleTest do
  @moduledoc false

  use ExUnit.Case
  doctest Codeowners.Rule

  alias Codeowners.Rule

  describe "build" do
    test "it gives a pattern, regex, and owner list" do
      rule = Rule.build("* @team # comment")

      assert "*" = rule.pattern
      assert %Regex{} = rule.regex
      assert ["@team"] = rule.owners
    end

    test "it ignores inline comments" do
      assert %Rule{owners: ["@team"]} = Rule.build("* @team # comment")
    end
  end

  describe "regex" do
    test "matches *" do
      regex = Rule.regex("*")
      assert Regex.match?(regex, "/test")
    end

    test "matches * with extension" do
      regex = Rule.regex("*.js")

      assert Regex.match?(regex, "test.js")
      refute Regex.match?(regex, "test.ts")
    end

    test "matches directory starting at root" do
      regex = Rule.regex("/build/logs/")

      assert Regex.match?(regex, "/build/logs/test.log")
      refute Regex.match?(regex, "/dev/build/logs/test.log")
    end

    test "matches rootless directory" do
      regex = Rule.regex("docs/")

      assert Regex.match?(regex, "/app/docs/setup/info.md")
    end

    test "matches directory with *" do
      regex = Rule.regex("docs/*")

      assert Regex.match?(regex, "docs/getting-started.md")
      refute Regex.match?(regex, "docs/build-app/troubleshooting.md")
    end

    test "matches /**" do
      regex = Rule.regex("/docs/**")

      assert Regex.match?(regex, "/docs/setup/dev/getting-started.md")
    end

    test "escapes ." do
      regex = Rule.regex("file.ex")

      assert Regex.match?(regex, "file.ex")
      refute Regex.match?(regex, "fileaex")
    end
  end
end

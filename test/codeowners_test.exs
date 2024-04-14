defmodule CodeownersTest do
  @moduledoc false

  use ExUnit.Case
  doctest Codeowners

  describe "load" do
    test "gives a %Codeowners{}" do
      path = Path.expand("./test/CODEOWNERS")
      assert %Codeowners{} = Codeowners.load(path)
    end
  end

  describe "build" do
    test "gives a %Codeowners{}" do
      assert %Codeowners{} = Codeowners.build()
    end

    test "it ignores blank lines" do
      assert %Codeowners{} = Codeowners.build("\n\n\n")
    end

    test "it ignores comments" do
      assert %Codeowners{} = Codeowners.build("#\n#\n#\n#")
    end
  end

  describe "rule_for_path" do
    test "gives a %Codeowners.Rule{}" do
      codeowners = Codeowners.build()
      assert %Codeowners.Rule{owners: []} = Codeowners.rule_for_path(codeowners, "./test")
    end

    test "matches *" do
      codeowners = Codeowners.build("* @team")
      assert %Codeowners.Rule{owners: ["@team"]} = Codeowners.rule_for_path(codeowners, "/test")
    end

    test "matches * with extension" do
      codeowners = Codeowners.build("*.js @team")

      assert %Codeowners.Rule{owners: ["@team"]} =
               Codeowners.rule_for_path(codeowners, "/test.js")

      assert %Codeowners.Rule{owners: ["@team"]} !=
               Codeowners.rule_for_path(codeowners, "/test.ts")
    end

    test "matches directory starting at root" do
      codeowners = Codeowners.build("/build/logs/ @team")

      assert %Codeowners.Rule{owners: ["@team"]} =
               Codeowners.rule_for_path(codeowners, "/build/logs/test.log")

      assert %Codeowners.Rule{owners: ["@team"]} !=
               Codeowners.rule_for_path(codeowners, "/dev/build/logs/test.log")
    end

    test "matches rootless directory" do
      codeowners = Codeowners.build("docs/ @team")

      assert %Codeowners.Rule{owners: ["@team"]} =
               Codeowners.rule_for_path(codeowners, "/app/docs/setup/info.md")
    end

    test "matches directory with *" do
      codeowners = Codeowners.build("docs/* @team")

      assert %Codeowners.Rule{owners: ["@team"]} =
               Codeowners.rule_for_path(codeowners, "docs/getting-started.md")

      assert %Codeowners.Rule{owners: []} =
               Codeowners.rule_for_path(codeowners, "docs/build-app/troubleshooting.md")
    end

    test "matches /**" do
      codeowners = Codeowners.build("/docs/** @team")

      assert %Codeowners.Rule{owners: ["@team"]} =
               Codeowners.rule_for_path(codeowners, "/docs/setup/dev/getting-started.md")
    end

    test "it returns the last match" do
      codeowners =
        Codeowners.build("""
          *           @team-1
          /docs/*     @team-2
          /docs/*.md  @team-3
        """)

      assert %Codeowners.Rule{owners: ["@team-3"]} =
               Codeowners.rule_for_path(codeowners, "/docs/getting-started.md")
    end
  end

  describe "rule_for_module" do
    test "gives a rule" do
      codeowners = Codeowners.build()
      module = Codeowners
      assert %Codeowners.Rule{} = Codeowners.rule_for_module(codeowners, module)
    end
  end
end

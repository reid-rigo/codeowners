defmodule CodeownersTest do
  @moduledoc false

  use ExUnit.Case
  doctest Codeowners

  describe "load" do
    test "gives a %Codeowners{}" do
      assert %Codeowners{} = Codeowners.load("priv/CODEOWNERS")
    end

    test "root argument" do
      assert "/opt/my-project" = Codeowners.load("priv/CODEOWNERS", root: "/opt/my-project").root
    end

    test "line number" do
      codeowners = Codeowners.load("priv/CODEOWNERS")
      rule = codeowners.rules |> Enum.find(fn r -> r.pattern == "*.txt" end)
      assert 27 = rule.line_number
    end
  end

  describe "build" do
    test "gives a %Codeowners{}" do
      assert %Codeowners{} = Codeowners.build()
    end

    test "ignores blank lines" do
      assert %Codeowners{} = Codeowners.build("\n\n\n")
    end

    test "ignores comment lines" do
      assert %Codeowners{} = Codeowners.build("#\n#\n#\n#")
    end

    test "default root" do
      assert Codeowners.build().root
    end

    test "root argument" do
      assert "/opt/my-project" = Codeowners.build("", root: "/opt/my-project").root
    end

    test "trims trailing / from root argument" do
      assert "/opt/my-project" = Codeowners.build("", root: "/opt/my-project/").root
    end
  end

  describe "rule_for_path" do
    test "gives a %Codeowners.Rule{}" do
      codeowners = Codeowners.build()
      assert %Codeowners.Rule{owners: []} = Codeowners.rule_for_path(codeowners, "./test")
    end

    test "returns the last match" do
      codeowners =
        Codeowners.build("""
          *           @team-1
          /docs/*     @team-2
          /docs/*.md  @team-3
        """)

      assert %Codeowners.Rule{owners: ["@team-3"]} =
               Codeowners.rule_for_path(codeowners, "/docs/getting-started.md")
    end

    test "removes root from full paths" do
      codeowners =
        Codeowners.build("/README.md @team") |> Map.put(:root, "/Users/someone/project")

      assert %Codeowners.Rule{owners: ["@team"]} =
               Codeowners.rule_for_path(codeowners, "/Users/someone/project/README.md")
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

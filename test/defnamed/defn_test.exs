defmodule Defnamed.DefnTest do
  use ExUnit.Case
  require Defnamed.Support.DefnTest, as: DefnTest

  test "defn basic" do
    left = "hello"
    right = "world!"
    separator = ", "
    assert "hello, world!" == DefnTest.concat(left: left, right: right, separator: separator)
    assert "hello, world!" == DefnTest.concat(right: right, separator: separator, left: left)
  end

  test "defn optional" do
    left = "eli"
    right = "xir"
    assert "elixir" == DefnTest.concat(left: left, right: right)
    assert "elixir" == DefnTest.concat(right: right, left: left)
  end

  test "defn optional arity 0" do
    assert "" == DefnTest.concat()
  end

  test "defn business logic runtime error" do
    left = "foo"
    right = "bar"
    separator = 123

    assert_raise ArgumentError, "separator should be string, but got: 123", fn ->
      DefnTest.concat(left: left, right: right, separator: separator)
    end
  end

  test "defn compiletime error - not keyword" do
    assert_raise Defnamed.Exception.NotKeyword,
                 "Elixir.Defnamed.Support.DefnTest.concat argument should be keyword list which can contain only [:left, :right, :separator] keys without duplication, but argument is not a keyword: {:foo, [], #{
                   inspect(__MODULE__)
                 }}",
                 fn ->
                   quote do
                     foo = 123
                     require unquote(DefnTest)
                     DefnTest.concat(foo)
                   end
                   |> Code.compile_quoted()
                 end
  end

  test "defn compiletime error - invalid arg name" do
    assert_raise Defnamed.Exception.InvalidArgNames,
                 "Elixir.Defnamed.Support.DefnTest.concat argument should be keyword list which can contain only [:left, :right, :separator] keys without duplication, but got invalid :foo key",
                 fn ->
                   quote do
                     left = "foo"
                     right = "bar"
                     separator = 123
                     foo = "foo"
                     require unquote(DefnTest)
                     DefnTest.concat(left: left, right: right, separator: separator, foo: foo)
                   end
                   |> Code.compile_quoted()
                 end
  end

  test "defn compiletime error - key duplication" do
    assert_raise Defnamed.Exception.ArgNamesDuplication,
                 "Elixir.Defnamed.Support.DefnTest.concat argument should be keyword list which can contain only [:left, :right, :separator] keys without duplication, but keys [:separator] are duplicated",
                 fn ->
                   quote do
                     left = "foo"
                     right = "bar"
                     separator = 123
                     require unquote(DefnTest)
                     DefnTest.concat(left: left, right: right, separator: separator, separator: separator)
                   end
                   |> Code.compile_quoted()
                 end
  end

  test "defn pattern matching" do
    uri = URI.parse("https://dan.github.io")
    correct_user = "dan"
    incorrect_user = "jassy"
    assert DefnTest.validate_homepage(uri: uri, user: correct_user)
    refute DefnTest.validate_homepage(uri: uri, user: incorrect_user)
  end

  test "defn test default arguments" do
    uri = URI.parse("https://anon.github.io")
    assert DefnTest.validate_homepage(uri: uri)
  end

  test "defn required args" do
    assert_raise Defnamed.Exception.MissingRequiredArgs,
                 "Elixir.Defnamed.Support.DefnTest.validate_homepage argument should be keyword list which can contain only [:uri, :user] keys without duplication, and mandatory [:uri] keys, but required :uri key is not presented",
                 fn ->
                   quote do
                     require unquote(DefnTest)
                     user = "jessy"
                     DefnTest.validate_homepage(user: user)
                   end
                   |> Code.compile_quoted()
                 end
  end

  test "defn can combine" do
    uri = URI.parse("https://dan.github.io")
    user = "dan"
    assert "homepage is good for you, dan" == DefnTest.generate_message(uri: uri, user: user)
    user = "jessy"
    assert "homepage is invalid for you, jessy" == DefnTest.generate_message(uri: uri, user: user)
  end
end

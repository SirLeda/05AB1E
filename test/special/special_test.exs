defmodule SpecialOpsTest do
    use ExUnit.Case
    alias Reading.Reader
    alias Parsing.Parser
    alias Interp.Interpreter
    alias Interp.Stack
    alias Interp.Environment
    alias Interp.Functions

    def evaluate(code) do
        code = Parser.parse(Reader.read(code))
        {stack, environment} = Interpreter.interp(code, %Stack{}, %Environment{})
        {result, _, _} = Stack.pop(stack, environment)

        assert is_map(result) or is_number(result) or is_bitstring(result) or is_list(result)

        Functions.eval(result)
    end

    test "wrap stack into array" do
        assert evaluate("1 2 3)") == ["1", "2", "3"]
    end

    test "reverse stack" do
        assert evaluate("1 2) 3r)ï") == [3, [1, 2]]
    end

    test "copy paste" do
        assert evaluate("1© 2®") == "1"
        assert evaluate("1© 2)") == ["1", "2"]
        assert evaluate("1© 2®)") == ["1", "2", "1"]
    end

    test "for loop [0, N)" do
        assert evaluate("5FN} N)") == [0, 1, 2, 3, 4, 0]
        assert evaluate("3F3FN} N})") == [0, 1, 2, 0, 0, 1, 2, 1, 0, 1, 2, 2]
    end

    test "for loop [1, N)" do
        assert evaluate("5GN} N)") == [1, 2, 3, 4, 0]
        assert evaluate("3G3GN} N})") == [1, 2, 1, 1, 2, 2]
        assert evaluate("3G\"abc\"})") == ["abc", "abc"]
    end

    test "for loop [0, N]" do
        assert evaluate("5ƒN} N)") == [0, 1, 2, 3, 4, 5, 0]
        assert evaluate("2ƒ2ƒN} N})") == [0, 1, 2, 0, 0, 1, 2, 1, 0, 1, 2, 2]
        assert evaluate("3ƒ\"abc\"})") == ["abc", "abc", "abc", "abc"]
    end

    test "filter program" do
        assert evaluate("5LʒÈ") == [2, 4]
        assert evaluate("10Lʒ3%>") == [3, 6, 9]
        assert evaluate("∞ʒ3%>}10£") == [3, 6, 9, 12, 15, 18, 21, 24, 27, 30]
    end

    test "for each program" do
        assert evaluate("5LεÈ") == [0, 1, 0, 1, 0]
        assert evaluate("∞εÈ}5£") == [0, 1, 0, 1, 0]
    end

    test "sort by program" do
        assert evaluate("5LΣÈ") == [1, 3, 5, 2, 4]
        assert evaluate("12345 123 123456789) Σg") == ["123", "12345", "123456789"]
    end

    test "run until no change" do
        assert evaluate("3LLLΔO") == 15
    end

    test "break out of loop" do
        assert evaluate("10FN N3Q#})") == [0, 1, 2, 3]
        assert evaluate("10FN2Q# 10FN N3Q#} 1ï})") == [0, 1, 2, 3, 1, 0, 1, 2, 3, 1]
    end

    test "map command for each" do
        assert evaluate("5L€>") == [2, 3, 4, 5, 6]
        assert evaluate("5L€D") == [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
    end
end
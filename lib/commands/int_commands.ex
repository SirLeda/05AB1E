defmodule Commands.IntCommands do

    alias Interp.Functions
    alias Commands.GeneralCommands

    # All characters available from the 05AB1E code page, where the
    # alphanumeric digits come first and the remaining characters
    # ranging from 0x00 to 0xff that do not occur yet in the list are appended.
    def digits, do: digits = String.to_charlist(
                             "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmno" <>
                             "pqrstuvwxyzǝʒαβγδεζηθвимнт\nΓΔΘιΣΩ≠∊∍∞₁₂₃₄₅₆ !\"#$%" <>
                             "&'()*+,-./:;<=>?@[\\]^_`{|}~Ƶ€Λ‚ƒ„…†‡ˆ‰Š‹ŒĆŽƶĀ‘’“”–" <>
                             "—˜™š›œćžŸā¡¢£¤¥¦§¨©ª«¬λ®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉ" <>
                             "ÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ")
    
    def factorial(0), do: 1
    def factorial(value), do: factorial(value, 1)
    def factorial(1, acc), do: acc
    def factorial(value, acc), do: factorial(value - 1, acc * value)

    def pow(n, k) do
        cond do
            k < 0 -> 1 / pow(n, -k, 1)
            true -> pow(n, k, 1)
        end 
    end
    defp pow(_, 0, acc), do: acc
    defp pow(n, k, acc) when k > 0 and k < 1, do: acc * :math.pow(n, k)
    defp pow(n, k, acc), do: pow(n, k - 1, n * acc)

    # Modulo operator:
    #  -x.(f|i) % -y.(f|i)     -->  -(x.(f|i) % y.(f|i))
    #  -x.f % y.f              -->  (y.f - (x.f % y.f)) % y.f
    #  x.f % -y.f              -->  -(-x.f % y.f)
    #  x.(f|i) % y.(f|i)       -->  ((x / y) % 1) * y.(f|i)
    #  -x.i % -y.i             -->  -(x.i % y.i) 
    #  -x.i % y.i              -->  (y.i - (x.i % y.i)) % y.i 
    #  x.i % -y.i              -->  -(-x.i % y.i)
    #  x.i % y.i               -->  rem(x.i, y.i)
    def mod(dividend, divisor) when dividend < 0 and divisor < 0, do: -mod(-dividend, -divisor)
    def mod(dividend, divisor) when is_float(divisor) do
        cond do
            dividend < 0 and divisor > 0 ->
                case mod(-dividend, divisor) do
                    0 -> 0
                    x -> divisor - x
                end
            dividend > 0 and divisor < 0 -> -mod(-dividend, -divisor)
            true -> mod(dividend / divisor, 1) * divisor
        end
    end
    def mod(dividend, divisor) when is_float(dividend) and is_integer(divisor) do
        int_part = trunc(dividend)
        float_part = dividend - int_part
        mod(int_part, divisor) + float_part
    end
    def mod(dividend, divisor) when is_integer(dividend) and is_integer(divisor) do
        cond do
            dividend < 0 and divisor > 0 ->
                case mod(-dividend, divisor) do
                    0 -> 0
                    x -> divisor - x
                end
            dividend > 0 and divisor < 0 -> -mod(-dividend, -divisor)
            true -> rem(dividend, divisor)
        end
    end

    def divide(dividend, divisor) when is_float(dividend) or is_float(divisor), do: trunc(dividend / divisor)
    def divide(dividend, divisor), do: div(dividend, divisor)

    def to_base(value, base) do
        Integer.digits(value, base) |> Enum.map(fn x -> Enum.at(digits(), x) end) |> List.to_string
    end

    def string_from_base(value, base) do
        list = to_charlist(value) |> Enum.map(fn x -> Enum.find_index(digits(), fn y -> x == y end) end)
        list_from_base(list, base)
    end

    def list_from_base(value, base) do
        value = Enum.to_list(value)
        {result, _} = Enum.reduce(value, {0, length(value) - 1}, fn (x, {acc, index}) -> {acc + pow(base, index) * x, index - 1} end)
        result
    end
end
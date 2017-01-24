defmodule FromFsharpTest do
    use ExUnit.Case
    alias Fsharpy.FromFsharp

    doctest FromFsharp

    test "get_val for `let x = 5`" do
        code = "val x : int = 5"
        assert %{"x" => 5} == FromFsharp.get_val(code)
    end

    test "get_val for `let pi = 3.14`" do
        code = "val pi : float = 3.14"
        assert %{"pi" => 3.14} == FromFsharp.get_val(code)
    end

    test "get_val for `let f = false`" do
        code = "val f : bool = false"
        assert %{"f" => false} == FromFsharp.get_val(code)
    end

    test "get_val for `let t = true`" do
        code = "val t : bool = true"
        assert %{"t" => true} == FromFsharp.get_val(code)
    end

    test "get_val for list of integers" do
        code = "val nums : int list = [1; 2; 3; 4; 5]"
        assert %{"nums" => [1,2,3,4,5]} == FromFsharp.get_val(code)
    end

    test "get_val for `let tup = (2,3)`" do
        code = "val tup : int * int = (2, 3)"
        assert %{"tup" => {2,3}} == FromFsharp.get_val(code)
    end

    test "get_val for `let tup = (2.5,4.5)`" do
        code = "val tup : float * float = (2.5, 4.5)"
        assert %{"tup" => {2.5,4.5}} == FromFsharp.get_val(code)
    end

    test "get_vals for three lets" do
        code = "val x : int * int = (5, 10)\nval z : int = 10\nval it : int = 50"
        lines = FromFsharp.get_vals(code)

        assert(lines == [%{"x" => {5, 10}},
                        %{"z" => 10},
                        %{"it" => 50}])
    end
end

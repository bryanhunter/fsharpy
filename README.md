# fsharpy

**Access F# interactive (FSI) from Elixir.**

## Getting started

FSharpy requires that either `fsi.exe` (on Windows) or `fsharpi` (On Mac or Linux) is installed and in your path.

Add Fsharpy to your mix dependencies.

## Usage from IEX

To start an Fsharpy session...
```
iex> {:ok, p} = Fsharpy.start_ink
{:ok, #PID<0.142.0>}
```

Once an Fsharpy session has been started, you can use the `print` function to
send code to be evaluated in F# and have the results printed to IEX.
```
iex> Fsharpy.print p, "let x = 21 * 2"

F#: val x : int = 42
:ok

iex> Fsharpy.print p, "#help"

F#: F# Interactive directives:
F#:
F#:     #r "file.dll";;        Reference (dynamically load) the given DLL
F#:     #I "path";;            Add the given search path for referenced DLLs
F#:     #load "file.fs" ...;;  Load the given file(s) as if compiled and referenced
F#:     #time ["on"|"off"];;   Toggle timing on/off
F#:     #help;;                Display help
F#:     #quit;;                Exit
F#:
F#:   F# Interactive command line options:
F#:
F#:       See 'fsharpi --help' for options
:ok
```

To evaluate F# code and get results that can be used programatically in Elixir
you can use the `eval` function

```
iex> Fsharpy.eval p, "let x = 10"
[%{"x" => 10}]

iex> Fsharpy.eval p, "let y = x + 5"
[%{"y" => 15}]

iex> [map] = Fsharpy.eval p, "[1;2;3;4;5] |> List.map(fun n -> n * x)"
[%{"it" => [10, 20, 30, 40, 50]}]

iex> map["it"] |> Enum.reverse
[50, 40, 30, 20, 10]
```

To shut down the Fsharpy session
```
iex>  Fsharpy.quit p
:ok
```

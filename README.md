# Jieko

[![CI](https://github.com/Roger-luo/Jieko.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/Roger-luo/Jieko.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/Roger-luo/Jieko.jl/graph/badge.svg?token=8EIbN4OPo2)](https://codecov.io/gh/Roger-luo/Jieko.jl)
[![][docs-stable-img]][docs-stable-url]
[![][docs-dev-img]][docs-dev-url]

Documentation as interfaces. Julia uses docstrings to define interfaces. This is a flexible way of creating interfaces in a dynamic language, but also creates trouble for automation and tooling. Jieko is a package that provides a infrastructure for defining interfaces that works with DocStringExtension with precisely the signature of the interface.

## Installation

<p>
Jieko is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package. To install Jieko,
    please <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press <kbd>]</kbd>
    key in the REPL to use the package mode, then type the following command
</p>

```julia
pkg> add Jieko
```

## Example

You only need to use the `@interface` macro and if you have [DocStringExtensions](https://github.com/JuliaDocs/DocStringExtensions.jl) setup, you can use the `INTERFACE` stub to generate the interface definition in the docstring similar to the `SIGNATURES` for methods.

```julia
using Jieko: @interface, INTERFACE

"""
$INTERFACE

my lovely interface
"""
@interface jieko(x::Real) = x
```

we can also compare with the `SIGNATURES` from `DocStringExtensions`:

```julia
using DocStringExtensions: SIGNATURES

"""
$SIGNATURES

my lovely method
"""
doc_string_ext(x::Real) = x
```

they result in the following

```julia
help?> TestReadmeExample.goo
  goo(x)
  

  my lovely method

help?> TestReadmeExample.foo
  public Main.TestReadmeExample.foo(x::Real)

  my lovely interface
```

In summary, the `@interface` macro from Jieko records the precise interface signature of your definition in the docstring, instead of guessing them from Julia's method table (`SIGNATURES`).

## License

MIT License

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://Roger-luo.github.io/Jieko.jl/dev/
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://Roger-luo.github.io/Jieko.jl/stable

"""
    @export_all_interfaces <begin ... end>

Wrap all interfaces from the module in which this macro is called in a `Prelude` module
and export them. This is useful for exporting all interfaces from a module to be used
in other modules.

Optionally, you can pass a list of extra symbols to be exported along with the interfaces.

The concept of `Prelude` is borrowed from rust, where it is used to give users an explicit
way to import all the symbols from a package. This is useful for the package authors to
provide a default set of symbols to be used by the users via `using MyPackage.Prelude`
without giving them the easy way of importing everything from the package via `using MyPackage`.

Because `Prelude` module only contains the API symbols, it makes it easier for the toolchain
to check the APIs without mixing them with the implementation details.

# Example

```julia
module MyModule
using Jieko.Prelude # load everything you need from Jieko

@interface foo(x::Float64)::Int = 2

# export interface `foo` and some extra symbols
@export_all_interfaces begin
    @interface
    @export_all_interfaces
    INTERFACE
    INTERFACE_LIST
    not_implemented_error
end
end
```
"""
macro export_all_interfaces()
    return esc(export_all_interfaces_m(__module__))
end

macro export_all_interfaces(extras)
    return esc(export_all_interfaces_m(__module__, collect_names(extras)))
end

function relative_using(parent::Symbol, names::Symbol...)
    body = Expr(:(:), Expr(:., :., :., parent))
    for name in names
        push!(body.args, Expr(:., name))
    end
    return Expr(:using, body)
end

function export_all_interfaces_m(mod::Module, extras::Vector{Symbol}=Symbol[])
    isdefined(mod, INTERFACE_STUB) || return nothing
    stub = getfield(mod, INTERFACE_STUB)
    stmts = expr_map(stub) do (name, method)
        quote
            $(relative_using(nameof(mod), method.name))
            export $(method.name)
        end
    end

    extra_stmts = expr_map(extras) do name
        quote
            $(relative_using(nameof(mod), name))
            export $(name)
        end
    end

    return Expr(:toplevel, Expr(:module, true, :Prelude, quote
        $(relative_using(nameof(mod), nameof(mod)))
        export $(nameof(mod))
        $stmts
        $extra_stmts
    end))
end

function collect_names(extras::Expr)::Vector{Symbol}
    Meta.isexpr(extras, :block) || throw(ArgumentError("expect begin ... end"))

    names = Vector{Symbol}()
    for stmt in extras.args
        stmt isa LineNumberNode && continue
        stmt isa Symbol && push!(names, stmt)
        Meta.isexpr(stmt, :macrocall) && if length(stmt.args) == 2
            push!(names, stmt.args[1])
        else
            throw(ArgumentError("expect @<macro_name>"))
        end
    end
    return names
end

"""
    @export_all_interfaces

Wrap all interfaces from the module in which this macro is called in a `Prelude` module
and export them. This is useful for exporting all interfaces from a module to be used
in other modules.

The concept of `Prelude` is borrowed from rust, where it is used to give users an explicit
way to import all the symbols from a package. This is useful for the package authors to
provide a default set of symbols to be used by the users via `using MyPackage.Prelude`
without giving them the easy way of importing everything from the package via `using MyPackage`.

Because `Prelude` module only contains the API symbols, it makes it easier for the toolchain
to check the APIs without mixing them with the implementation details.
"""
macro export_all_interfaces()
    return esc(export_all_interfaces_m(__module__))
end

function export_all_interfaces_m(mod::Module)
    isdefined(mod, INTERFACE_STUB) || return nothing
    stub = getfield(mod, INTERFACE_STUB)
    stmts = expr_map(stub) do (name, method)
        quote
            using ..$(nameof(mod)): $(method.name)
            export $(method.name)
        end
    end
    return Expr(:toplevel, Expr(:module, true, :Prelude, stmts))
end

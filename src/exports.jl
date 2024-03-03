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

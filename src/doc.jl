# DocStringExtensions plugin
struct InterfaceSignature <: Abbreviation end

"""
    const INTERFACE = InterfaceSignature()

Similar to `SIGNATURES` but has more precise method
information obtained directly from the [`@interface`](@ref)
macro.
"""
const INTERFACE = InterfaceSignature()

function DocStringExtensions.format(::InterfaceSignature, buf, doc)
    binding = doc.data[:binding]
    object = Docs.resolve(binding)
    mod = parentmodule(object)
    if !isdefined(mod, INTERFACE_STUB)
        return nothing
    end
    stub = getfield(mod, INTERFACE_STUB)
    haskey(stub, nameof(object)) || return nothing
    interface = stub[nameof(object)]
    if Base.isexported(mod, nameof(object))
        signature = sprint(show, interface; context=:show_mod=>false)
        return print(buf, "    export ", signature)
    else
        return print(buf, "    public ", interface)
    end
end

struct InterfaceList <: Abbreviation end

"""
    const INTERFACE_LIST = InterfaceList()

List all the interface methods of a module. It shows
nothing if the binded object is not a module.
"""
const INTERFACE_LIST = InterfaceList()

function DocStringExtensions.format(::InterfaceList, buf, doc)
    binding = doc.data[:binding]
    mod = Docs.resolve(binding)
    mod isa Module || return nothing # NOTE: or error?

    isdefined(mod, INTERFACE_STUB) || return nothing
    stub = getfield(mod, INTERFACE_STUB)
    println(buf, "### Interfaces\n\n")
    for (name, method) in stub
        println(buf, "    ", method)
    end
end

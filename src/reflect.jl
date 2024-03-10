"""
$INTERFACE

Return the interface stub storage for a module.
"""
@interface function interfaces(mod::Module)
    if isdefined(mod, INTERFACE_STUB)
        return getfield(mod, INTERFACE_STUB)
    else
        return Dict{Symbol, InterfaceMethod}()
    end
end

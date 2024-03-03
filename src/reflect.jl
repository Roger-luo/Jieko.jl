"""
$INTERFACE

Return the interface stub storage for a module.
"""
@interface function interfaces(mod::Module)
    return get(mod, INTERFACE_STUB, Dict{Symbol, InterfaceMethod}())
end

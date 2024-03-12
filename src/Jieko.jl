module Jieko

using ExproniconLite: NoDefault, no_default, JLFunction, name_only, expr_map
using DocStringExtensions: DocStringExtensions, Abbreviation, SIGNATURES, TYPEDEF

const INTERFACE_STUB = Symbol("#Jieko##INTERFACE_STUB#")

include("interface.jl")
include("doc.jl")
include("exports.jl")
include("reflect.jl")
include("err.jl")

@export_all_interfaces begin
    @interface
    @export_all_interfaces
    INTERFACE
    INTERFACE_LIST
    not_implemented_error
end

end # Jieko

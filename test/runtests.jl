using Test
using ExproniconLite: NoDefault, no_default
using Jieko: Jieko, InterfaceMethod, TypeAnnotation, WhereParam, @interface, INTERFACE


InterfaceMethod(
    mod = Main,
    name = :sin,
    arg_names = [:x, :y],
    arg_types = [TypeAnnotation(:Int, "Int64"), nothing],
    kwargs_names = [:z],
    kwargs_types = [TypeAnnotation(:Int, "Int64")],
    kwargs_defaults = [no_default],
    where_params = [WhereParam(:T, TypeAnnotation(:Int, "Int64"))],
    return_type = TypeAnnotation(:Int, "Int64"),
)

"""
$INTERFACE
"""
@interface foo(x::Float64)::Int = 2


module TestJieko
using Jieko: INTERFACE, @interface, @export_all_interfaces

"""
$INTERFACE
"""
@interface foo(x::Float64)::Int = 2

@export_all_interfaces
# @show @macroexpand(@export_all_interfaces)
end # TestJieko


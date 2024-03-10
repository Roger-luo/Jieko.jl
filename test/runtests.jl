using Test
using ExproniconLite: NoDefault, no_default
using Jieko: Jieko, InterfaceMethod, TypeAnnotation, WhereParam, @interface, INTERFACE

mt = InterfaceMethod(
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

show(devnull, mt) # for the sake of test coverage

"""
$INTERFACE_LIST
"""
module TestJieko
using Jieko: INTERFACE, INTERFACE_LIST, @interface, @export_all_interfaces

"""
$INTERFACE
"""
@interface foo(x::Float64)::Int = 2

@export_all_interfaces
# @show @macroexpand(@export_all_interfaces)
end # TestJieko

@testset "Jieko" begin
    @test names(TestJieko.Prelude) == [:Prelude, :foo]
    @test names(TestJieko) == [:TestJieko]
    md = @doc(TestJieko.foo)
    @test md.content[1].content[1].content[1].code == "public Main.TestJieko.foo(x::Float64) -> Int"

    md = @doc(TestJieko)
    md.content[1].content[1].content[2].code == "Main.TestJieko.foo(x::Float64) -> Int"
end # @testset "Jieko"

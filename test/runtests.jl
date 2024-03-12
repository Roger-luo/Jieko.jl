using Test
using ExproniconLite: NoDefault, no_default
using Jieko: Jieko, InterfaceMethod, TypeAnnotation, WhereParam, @interface, INTERFACE, interfaces

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

module TestEmptyModule
end # TestEmpty

@testset "Jieko" begin
    @test names(TestJieko.Prelude) == [:Prelude, :TestJieko, :foo]

    @static if VERSION > v"1.12-"
        # interface is public
        @test names(TestJieko) == [:TestJieko, :foo]
    else
        @test names(TestJieko) == [:TestJieko]
    end

    md = @doc(TestJieko.foo)
    @test contains(sprint(show, md), "public Main.TestJieko.foo(x::Float64) -> Int")

    md = @doc(TestJieko)
    @test contains(sprint(show, md), "Main.TestJieko.foo(x::Float64) -> Int")

    @test interfaces(TestJieko) isa Dict
    @test isempty(interfaces(TestEmptyModule))
    #TODO: add more specific tests for this
end # @testset "Jieko"


module TestReadmeExample
using Jieko: @interface, INTERFACE
using DocStringExtensions: SIGNATURES

"""
$INTERFACE

my lovely interface
"""
@interface jieko(x::Real) = x

"""
$SIGNATURES

my lovely method
"""
doc_string_ext(x::Real) = x

end # TestReadmeExample

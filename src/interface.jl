"""
$TYPEDEF

The annotation information of a type. This also stores the name user typed
in the annotation, e.g an alias of type is used instead of the original type
name. This is useful for printing the type annotation in docstrings.
"""
@kwdef struct TypeAnnotation
    expr::Union{Symbol, Expr}
    repr::String = string(expr)

    function TypeAnnotation(expr, repr)
        new(expr, repr)
    end
end

Base.show(io::IO, anno::TypeAnnotation) = print(io, anno.repr)

const Annotation = Union{TypeAnnotation, Nothing}

function map_to_annotation(coll)
    map(coll) do type
        if type === Any
            nothing
        else
            TypeAnnotation(type, string(type))
        end
    end
end

"""
$TYPEDEF

The type variable information of a function.
"""
@kwdef struct WhereParam
    name::Symbol
    bound::Annotation = nothing
end

function Base.show(io::IO, param::WhereParam)
    print(io, param.name)
    if param.bound isa TypeAnnotation
        print(io, " <: ")
        Base.show(io, param.bound)
    end
end

"""
$TYPEDEF

The signature information of an interface method.

!!! note
    This is only used for printing for now. Thus we do not store
    the actual type signature at the moment. We should think about
    how to store the type signature and use this info in the future.
"""
@kwdef struct InterfaceMethod
    mod::Module
    name::Symbol
    arg_names::Vector{Symbol} = []
    arg_types::Vector{Annotation} = []
    kwargs_names::Vector{Symbol} = []
    kwargs_types::Vector{Annotation} = []
    kwargs_defaults::Vector{Union{String, NoDefault}} = []
    where_params::Vector{WhereParam} = []
    return_type::Annotation = nothing

    function InterfaceMethod(
            mod,
            name,
            arg_names,
            arg_types,
            kwargs_names,
            kwargs_types,
            kwargs_defaults,
            where_params,
            return_type,
        )

        if length(arg_names) != length(arg_types)
            throw(ArgumentError("arg_names and arg_types must have the same length"))
        end

        if !(length(kwargs_names) == length(kwargs_types) == length(kwargs_defaults))
            throw(ArgumentError("kwargs_names, kwargs_types, and kwargs_defaults must have the same length"))
        end

        new(
            mod,
            name,
            arg_names,
            arg_types,
            kwargs_names,
            kwargs_types,
            kwargs_defaults,
            where_params,
            return_type,
        )
    end
end # InterfaceMethod

function Base.show(io::IO, interface::InterfaceMethod)
    if get(io, :show_mod, true)
        Base.show(io, interface.mod)
        print(io, ".")
    end

    print(io, interface.name)

    print(io, "(")
    for (i, (arg, type)) in enumerate(zip(interface.arg_names, interface.arg_types))
        i > 1 && print(io, ", ")
        Base.print(io, arg)
        if type isa TypeAnnotation
            print(io, "::")
            Base.show(io, type)
        end
    end # for (i, (arg, type))

    if !isempty(interface.kwargs_names)
        isempty(interface.arg_names) || print(io, "; ")
        for (i, (arg, type, default)) in enumerate(zip(interface.kwargs_names, interface.kwargs_types, interface.kwargs_defaults))
            i > 1 && print(io, ", ")
            Base.print(io, arg)
            if type isa TypeAnnotation
                print(io, "::")
                Base.show(io, type)
            end
            if default isa String
                print(io, " = ", default)
            end
        end # for (i, (arg, type, default))
    end # if !isempty(interface.kwargs_names)

    print(io, ")")

    if !isempty(interface.where_params)
        print(io, " where ")
        for (i, param) in enumerate(interface.where_params)
            i > 1 && print(io, ", ")
            Base.show(io, param)
        end # for (i, param)
    end # if !isempty(interface.where_params)

    if interface.return_type isa TypeAnnotation
        print(io, " -> ")
        Base.show(io, interface.return_type)
    end
end

"""
    @interface <function definition>

Mark a method definition as interface. This will help
the toolchain generating docstring and other things. The
interface method is usually the most generic one that errors.
"""
macro interface(fn)
    return esc(interface_m(__module__, fn))
end

function interface_m(mod::Module, fn)
    jl = JLFunction(fn)
    return quote
        $(emit_interface_stub_storage(mod))
        $Core.@__doc__ $(fn)
        $INTERFACE_STUB[$(QuoteNode(jl.name))] = $(emit_interface_stub(mod, jl))
        $(emit_public(mod, jl))
    end
end

function emit_public(mod::Module, jl::JLFunction)
    # see JuliaLang/julia/issues/51450
    @static if VERSION > v"1.11-"
        return Expr(:public, jl.name)
    else
        return
    end
end

function emit_interface_stub_storage(mod::Module)
    type = :($Base.Dict{$Base.Symbol,$(@__MODULE__).InterfaceMethod})
    if !isdefined(mod, INTERFACE_STUB)
        return :(const $INTERFACE_STUB = $type())
    end
    return nothing
end

function emit_interface_stub(mod::Module, jl::JLFunction)
    kwargs_names = isnothing(jl.kwargs) ? [] : name_only.(jl.kwargs)
    kwargs_types = isnothing(jl.kwargs) ? [] : type_only.(jl.kwargs)
    kwargs_defaults = if isnothing(jl.kwargs)
        []
    else
        map(jl.kwargs) do expr
            if Meta.isexpr(expr, :kw) || Meta.isexpr(expr, :(=))
                string(expr.args[2])
            else
                no_default
            end
        end
    end

    im = InterfaceMethod(;
        mod, jl.name,
        arg_names = name_only.(jl.args),
        arg_types = map_to_annotation(type_only.(jl.args)),
        kwargs_names = kwargs_names,
        kwargs_types = map_to_annotation(kwargs_types),
        kwargs_defaults = kwargs_defaults,
        return_type = isnothing(jl.rettype) ? nothing : TypeAnnotation(jl.rettype, string(jl.rettype)),
    )
    return im
end

function type_only(expr)
    expr isa Expr || return Any
    if Meta.isexpr(expr, :(::))
        length(expr.args) == 2 && return expr.args[2]
        return expr.args[1]
    end
    Meta.isexpr(expr, :kw) && return type_only(expr.args[1])
    Meta.isexpr(expr, :(=)) && return type_only(expr.args[1])
    Meta.isexpr(expr, :...) && return type_only(expr.args[1])
    return error("invalid expression: $expr")
end

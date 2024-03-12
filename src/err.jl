# common errors

struct NotImplementedError <: Exception end
Base.showerror(io::IO, e::NotImplementedError) = print(io, "Not implemented yet")
not_implemented_error() = throw(NotImplementedError())

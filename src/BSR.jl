module BSR

try
    include("paths.jl") # This file is generated by the package build script
catch
    error("Run Pkg.build(\"BSR\") first")
end

include("utils.jl")
include("prep_state.jl")
include("calc.jl")
include("load_matrices.jl")
include("load_states.jl")

end # module

fortran_double(s) = parse(Float64, replace(s, "D", "E"))

function parse_zf_block(block)
    lower = split(strip(block[1][5:end]))
    upper = split(strip(block[2][5:end]))
    len = split(block[4])[[4,7,10]]
    vel = split(block[5])
    Dict(:lower => lower[2],
         :upper => upper[2],
         :E1 => parse(Float64, lower[1]),
         :E2 => parse(Float64, upper[1]),
         :SL => fortran_double(len[1]),
         :SV => fortran_double(vel[1]),
         :GFL => fortran_double(len[2]),
         :GFV => fortran_double(vel[2]),
         :AKIL => fortran_double(len[3]),
         :AKIV => fortran_double(vel[3]))
end

function read_zf_res(directory::AbstractString,
                     name::AbstractString = "zf_res",
                     dd::AbstractString = "")
    blocks = []
    open("$(directory)/$(name)") do file
        readline(file)
        block = []
        for line in eachline(file)
            if strip(line) == ""
                push!(blocks, parse_zf_block(block))
                block = []
            else
                push!(block, line)
            end
        end
        push!(blocks, parse_zf_block(block))
    end

    if dd != ""
        mat_els = readdlm(dd)
        m,n = maximum(mat_els[:,1]),maximum(mat_els[:,2])
        m*n == length(blocks) || error("Incongruent transition matrix size")
        L = [fortran_double(s) for s in mat_els[:,3]]
        V = [fortran_double(s) for s in mat_els[:,4]]
        for i in eachindex(blocks)
            blocks[i][:DL] = L[i]
            blocks[i][:DV] = V[i]
        end
    end

    blocks
end

read_zf_res(directory::AbstractString,
            i::Integer, j::Integer) =
                read_zf_res(directory,
                            @sprintf("trans.%d_%d", i, j),
                            @sprintf("dd.%03d_%03d", i, j))

export read_zf_res

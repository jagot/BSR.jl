function knot_set(directory::AbstractString,
                  knot_set::Matrix)
    open("$(directory)/knot.dat", "w") do file
        for i = 1:size(knot_set,1)
            write(file, string(knot_set[i,2]), " ==> ", knot_set[i,1])
            write(file, '\n')
        end
        write(file, "***\n")
    end
end

function knot_set(directory::AbstractString,
                  order::Integer,
                  num_splines::Integer,
                  Z::Real,
                  E_max::Real,
                  r_max::Real)
    h_max = sqrt(1/E_max) # Only valid for order == 8 ?
    n = floor(log(8Z)/log(2))
    h_int = 1/2.0^n
    knots = ["order of splines (ks)" order
             "number of splines (ns)" num_splines
             "nuclear charge (z)" Z
             "step size from 0 to 1 (h for z*r, = (1/2)^n)" h_int
             "maximum step size (hmax for r)" h_max
             "maximum r (rmax)" r_max]
    knot_set(directory, knots)
    knots
end

function load_knot_set(directory::AbstractString)
    open(joinpath(directory, "knot.dat")) do file
        read_parm = T -> parse(T, split(readline(file), "==>")[1])
        knot_set = Dict()
        knot_set[:ks] = read_parm(Int)
        knot_set[:ns] = read_parm(Int)
        knot_set[:Z] = read_parm(Float64)
        knot_set[:h] = read_parm(Float64)
        knot_set[:hmax] = read_parm(Float64)
        knot_set[:rmax] = read_parm(Float64)
        readline(file)
        knot_set[:t] = Vector{Float64}()
        while length(knot_set[:t]) < knot_set[:ns] + knot_set[:ks]
            tt = map(s -> parse(Float64, s), split(readline(file)))
            append!(knot_set[:t], tt)
        end
        readline(file)
        knot_set[:n_inner_knots] = read_parm(Int)
        knot_set[:n_exp_knots] = read_parm(Int)
        knot_set[:n_intervals] = read_parm(Int)
        knot_set[:max_k2_Ry] = read_parm(Float64)
        knot_set
    end
end

function target(directory::AbstractString,
                target_descr::Matrix)
    open("$directory/target", "w") do file
        for i in 1:size(target_descr,1)
            if target_descr[i,1] != ""
                write(file, string(target_descr[i,1]))
                if target_descr[i,2] != ""
                    write(file, " = ", string(target_descr[i,2]))
                    if target_descr[i,3] != ""
                        write(file, " ! ", string(target_descr[i,3]))
                    end
                end
            else
                write(file, "--------")
            end
            write(file, '\n')
        end
    end
end

bsr_prep() = run(`$(bsr)/bsr_prep`)
bsr_conf() = run(`$(bsr)/bsr_conf`)

export knot_set, load_knot_set, target, bsr_prep, bsr_conf

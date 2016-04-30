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

export knot_set, target, bsr_prep, bsr_conf

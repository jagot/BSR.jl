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

separator(file) = write(file, "--------\n")
property(file, p, v, c) = write(file, "$p = $v ! $c\n")

function target(directory::AbstractString,
                heading::AbstractString,
                Z::Real, nelc::Integer,
                partial_waves::Vector{Term},
                targets::BSR.StateDict,
                perturbers::BSR.StateDict)
    open("$directory/target", "w") do file
        ntarg = sum([length(targets[t]) for t in keys(targets)])
        partial_waves = sort(collect(keys(perturbers)))
        # nlsp = length(partial_waves)
        kpert = sum([length(perturbers[p]) for p in keys(perturbers)])
        write(file, heading, "\n")
        separator(file)
        property(file, "coupling", "LS", "coupling scheme")
        property(file, "nz", Z, "nuclear charge")
        property(file, "nelc", nelc, "number of bound electrons")
        separator(file)
        property(file, "ntarg", ntarg, "number of targets")
        separator(file)
        for k in keys(targets)
            for t in targets[k]
                write(file, t, ".c\n")
            end
        end
        separator(file)
        property(file, "nlsp", nlsp, "number of partial waves")
        separator(file)
        for pw in partial_waves
            write(file, "$(string(pw)) $(pw.L) $(multiplicity(pw)) $(pw.parity)\n")
        end
        separator(file)
        property(file, "kpert", kpert, "number of perturbers")
        separator(file)
        for ti = eachindex(partial_waves)
            for p in perturbers[partial_waves[ti]]
                write(file, "$ti $p\n")
            end
        end
    end
    readall("$directory/target")
end

function load_target(directory::AbstractString)
    open(joinpath(directory, "target")) do file
        target = Dict()
        read_parm = T -> begin
            line = split(readline(file), "=")
            val = strip(split(line[2], "!")[1])
            target[symbol(strip(line[1]))] = T<:AbstractString ? val : parse(T, val)
        end
        expect_line = () -> begin
            line = readline(file)
            line[1]==line[2]=='-' || error("Expected divider")
        end
        readline(file)
        expect_line()
        coupling = read_parm(ASCIIString)
        read_parm(Int)
        read_parm(Int)
        expect_line()
        ntarg = read_parm(Int)
        expect_line()
        target[:targets] = []
        for i = 1:ntarg
            line = split(readline(file))
            t = Dict(:name => line[1],
                     :parity => parse(Int, line[5]),
                     :E => parse(Float64, line[6]),
                     :ncfg => parse(Int, line[7]))
            if coupling == "LS"
                t[:L] = parse(Int, line[3])
                t[:S] = parse(Int, line[4])
            else
                t[:J] = parse(Int, line[3])//2
            end
            push!(target[:targets], t)
        end
        expect_line()
        read_parm(Int)
        read_parm(Int)
        read_parm(Int)
        expect_line()
        nlsp = read_parm(Int)
        expect_line()
        target[:partial_waves] = map(1:nlsp) do i
            line = split(readline(file))
            a,b = parse(Int, line[2]),parse(Int, line[3])
            pw = Dict(:name => line[1],
                      :parity => parse(Int, line[4]))
            if coupling == "LS"
                pw[:L] = a
                pw[:S] = b
            else
                pw[:J] = a//2
            end
            pw
        end
        expect_line()
        kpert = read_parm(Int)
        expect_line()
        target[:perturbers] = Dict()
        for i = 1:kpert
            line = split(readline(file))
            pk = parse(Int, line[1])
            target[:perturbers][pk] = vcat(get(target[:perturbers], pk, [])..., line[2])
        end
        expect_line()
        readline(file)
        expect_line()
        for i = 1:nlsp
            line = split(readline(file))
            nch = parse(Int, line[5])
            target[:partial_waves][i][:channels] = map(1:nch) do j
                line = split(readline(file))
                Dict(:name => line[1],
                     :l => parse(Int, line[2]),
                     :target => parse(Int, line[3]),
                     :last_cfg => parse(Int, line[5]),
                     :K => (parse(Int, line[6])-1)//2)
            end
            expect_line()
        end
        target
    end
end

@bsr_exe bsr_prep
@bsr_exe bsr_conf

export knot_set, load_knot_set, target, load_target, bsr_prep, bsr_conf

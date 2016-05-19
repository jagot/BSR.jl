function load_bound_states(directory::AbstractString, k::Integer)
    dbl_pat = r"([ -])([0-9]).([0-9]+)D([+-])([0-9]+)" # Double-precision in Fortran: 0.0000D+00
    open(joinpath(directory, @sprintf("bound.%03d", k))) do file
        ns,kch,kcp,nhm,nbound,lpar,ispar,ipar =
            map(s -> parse(Float64, s),
                split(split(readline(file), "=>")[1]))
        map(1:nbound) do i
            label = split(readline(file))[2]
            E_au,E_bind,n_eff = map(s -> parse(Float64, s),
                                    split(split(readline(file), "=>")[1]))
            c = Vector{Float64}()
            while length(c) < nhm
                line = readline(file)
                ms = matchall(dbl_pat, line)
                t = map(ms) do m
                    parse(Float64, replace(m, "D", "E"))
                end
                append!(c, t)
            end
            Dict(:label => label,
                 :E_au => E_au, :E_bind => E_bind, :n_eff => n_eff,
                 :c => c)
        end
    end
end

export load_bound_states

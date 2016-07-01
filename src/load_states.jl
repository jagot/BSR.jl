function load_bound_states(directory::AbstractString, k::Integer)
    dbl_pat = r"([ -])([0-9]).([0-9]+)D([+-])([0-9]{2})" # Double-precision in Fortran: 0.0000D+00
    flt_pat = r"([ -])([0-9]).([0-9]+)E([+-])([0-9]{2})"
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

function asmatrix(v)
    V = Matrix{Float64}(length(v[1][:c]), length(v))
    for j = 1:length(v)
        V[:,j] = v[j][:c]
    end
    V
end

function eigenbasis(directory::AbstractString, k::Integer, Ip::Real)
    v = load_bound_states(directory, k)
    V = asmatrix(v)
    E = Float64[v[j][:E_bind]/27.211-Ip for j = eachindex(v)]
    E,V
end

function eigenbasis(directory::AbstractString,
                    krange::UnitRange{Int}, Ip::Real)
    @time E,V = zip(map(k -> eigenbasis(directory, k, Ip), krange)...)
    E = Vector{Float64}[EE for EE in E]
    V = Matrix{Float64}[V[k] for k=1:length(V)]
    E,V
end

export load_bound_states, eigenbasis

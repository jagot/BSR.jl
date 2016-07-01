using AST
using AtomicLevels

@bsr_exe cfile
@bsr_exe w_bsw

# The mixing files (.l/.j) are sorted according to energy, but the
# lowest eigenvector does not necessarily have index 1. For each value
# of J, find the indices of the eigenvectors in increasing energy
# order.
function load_mix_file(filename)
    j_pat = r"J =([ 0-9]+)"
    state_pat = filename[end] == 'l' ? r"([A-Z])$" : r"([0-9])([A-Z])([0-9]*)$"
    states = []
    open(filename) do file
        name,Z,nel,ncfg = split(readline(file))[[1,4,7,10]]
        j = 0
        for line in eachline(file)
            if ismatch(j_pat, line)
                j = parse(Int,match(j_pat, line)[1])
            end
            if ismatch(state_pat, line)
                n = parse(Int,match(r"([0-9]+)", line)[1])
                push!(states, (n,j))
            end
        end
    end
    states
end

function bsr_prep_state(orig_wfn::AbstractString,
                        name::AbstractString,
                        filetype::AbstractString,
                        filename::AbstractString,
                        directory::AbstractString;
                        n_eiv::Integer = 1,
                        J2::Integer = 0,
                        cutoff::Real = 0)
    orig_dir = dirname(orig_wfn)
    wfn_filename = basename(orig_wfn)
    cpf(orig_wfn, "$directory/$(name).w")
    for ending in "c$(filetype)"
        cpf("$(orig_dir)/$(name).$(ending)", "$directory/$(name).$(ending)")
    end
    dir_run(directory) do
        mix_file = "$(name).$(filetype)"
        # Read out set index (?) corresponding to the n:th lowest
        # eigenvector
        nn = filter(n -> n[2] == J2, load_mix_file(mix_file))[n_eiv][1]
        cfile(mix_file, nn, J2, "$(filename).c", cutoff)
        w_bsw("$(name).w")
        name != filename && mv("$(name).bsw", "$(filename).bsw", remove_destination = true)
        cpf("$(name).w", "$(filename).w")
    end
end

function bsr_prep_state(state::AST.LevelVertex,
                        filename::AbstractString,
                        directory::AbstractString,
                        cutoff::Real = 0)
    bsr_prep_state(state.wfn, string(state.term), "l",
                   filename, directory; cutoff = cutoff)
end

function add_state!(states::StateDict,
                    term::Term,
                    state::AbstractString)
    if length(get(states, term, [])) == 0
        states[term] = AbstractString[]
    end
    push!(states[term], state)
end

function bsr_prep_states_ls!(directory::AbstractString,
                             wfn::AbstractString,
                             ts::Vector{Term},
                             cfgs::Vector{Config},
                             states::StateDict;
                             filetype::AbstractString = "l",
                             cutoff = 0,
                             all_eivs::Bool = true)
    ts_eiv = all_eivs ? count_common_terms(cfgs, ts) : ones(Int, length(ts))
    for (j,term) in enumerate(ts)
        for i = 1:ts_eiv[j]
            name = "$(string(term))_$i"
            bsr_prep_state(wfn, string(term), filetype,
                           name, directory;
                           n_eiv = i,
                           cutoff = cutoff)
            add_state!(states, term, name)
        end
    end
end

export bsr_prep_state, state_dict, bsr_prep_states_ls!

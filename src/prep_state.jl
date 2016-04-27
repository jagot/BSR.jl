using AST

function bsr_prep_state(state, filename, directory, cutoff = 0)
    state_name = AST.active_file(state.config, state.term)
    orig_dir = dirname(state.wfn)
    for ending in "wcl"
        cpf("$(orig_dir)/$(state_name).$(ending)", "$directory/$(state_name).$(ending)")
    end
    dir_run(directory) do
        run(`$(bsr)/cfile $(state_name).l 1 0 $(filename).c $cutoff`)
        run(`$(bsr)/w_bsw $(state_name).w`)
        mv("$(state_name).bsw", "$(filename).bsw", remove_destination = true)
    end
end

export bsr_prep_state

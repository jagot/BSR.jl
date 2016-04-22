function build_args(kwargs)
    map(kwargs) do kv
        "$(kv[1])=$(kv[2])"
    end
end

macro bsr_exe(exe)
    exe_str = string(exe)
    @eval begin
        function ($exe)(args...; kwargs...)
            cmd = string(bsr, "/", $exe_str)
            run(`$cmd $args $(build_args(kwargs))`)
        end
        export $exe
    end
end

@bsr_exe bsr_breit
@bsr_exe bsr_mat
@bsr_exe bsr_hd

@bsr_exe mult
@bsr_exe bsr_dmat
@bsr_exe bsr_phot

function photo(photo_inp::Matrix)
    open("bsr_phot.inp", "w") do file
        write(file, "-------\n")
        for i = 1:size(photo_inp,1)
            if photo_inp[i,1] != ""
                write(file,
                      string(photo_inp[i,1]), " = ",
                      string(photo_inp[i,2]), "\n")
            end
        end
        write(file, "-------\n")
    end
    
    bsr_phot()
end

export photo

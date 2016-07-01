using Lumberjack

@bsr_exe bsr_breit
@bsr_mpi_exe bsr_breit_mpi
@bsr_exe bsr_mat
@bsr_mpi_exe bsr_mat_mpi
@bsr_exe bsr_hd

@bsr_exe mult
@bsr_exe bsr_dmat
@bsr_exe bsr_phot

function dipole(cfg1, cfg2, t1, t2, trans="E1", args...; kwargs...)
    mult(cfg1, cfg2, trans)
    bsr_dmat(cfg1, cfg2, t1, t2, args...; kwargs...)
end

function photo(photo_inp::Matrix, klsp::Integer)
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
    debug("bsr_phot.inp:\n$(photo_inp)")
    
    bsr_phot(klsp = klsp)
end

export dipole, photo

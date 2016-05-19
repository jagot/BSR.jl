using UnFortran

function load_hamiltonian_overlap_matrices(directory::AbstractString, n::Integer, verbose::Bool = false)
    fort_open(joinpath(directory, @sprintf("bsr_mat.%03d", n))) do file
        ns,nch,ncp = read(file, Int32, Int32, Int32)
        nhm = ns*nch + ncp
        verbose && println("Number of B-splines: ", ns)
        verbose && println("Number of channels: ", nch)
        verbose && println("Number of bound (N+1)-electron configurations: ", ncp)
        verbose && println("Interaction matrix dimensions: $(nhm)×$(nhm)")

        # Load overlap matrix
        om = Array(Float64, ns, ns)
        sparse(read!(file, om))
        jc = 0
        while true # What is this?
            ic,jc = read(file, Int32, Int32)
            verbose && println((ic,jc))
            ic <= 0 && break
            idim = ic <= nch ? ns : 1
            jdim = jc <= nch ? ns : 1
            S = Vector{Float64}(idim*jdim)
            read!(file, S)
            verbose && println("S: ", size(S))
        end
        diag_ovl = jc

        # Load interaction matrix (Hamiltonian)
        ad = Array(Float64, ns, ns, nch)
        for i = 1:nch
            read!(file, sub(ad, :, :, i))
        end
        while true # What is this?
            ic,jc = read(file, Int32, Int32)
            verbose && println((ic,jc))
            ic <= 0 && break
            idim = ic <= nch ? ns : 1
            jdim = jc <= nch ? ns : 1
            S = Vector{Float64}(idim*jdim)
            read!(file, S)
            verbose && println("S: ", size(S))
        end
        diag_hm = jc

        verbose && println(size(ad))
        ad,om
    end
end

function load_dipole(directory::AbstractString, k1::Integer, k2::Integer)
    fort_open(joinpath(directory, "d.00$(k1)_00$(k2)")) do file
        m,n = read(file, Int32, Int32)
        L = Array(Float64, m, n)
        for j = 1:n
            read!(file, sub(L, :, j))
        end
        V = Array(Float64, m, n)
        for j = 1:n
            read!(file, sub(V, :, j))
        end
        L,V
    end
end

function load_dipole_vec(directory::AbstractString, k::Integer)
    fort_open(joinpath(directory, "d.00$(k)")) do file
        il, is, ip, E, ndm = read(file, Int32, Int32, Int32, Float64, Int32)
        ili, isi, ipi, Ei = read(file, Int32, Int32, Int32, Float64)
        println((il,is,ip,E,ndm))
        println((ili,isi,ipi,Ei))
        dip = Array(Float64, 2, ndm)
        read!(file, dip)'
    end
end

export load_hamiltonian_overlap_matrices, load_dipole, load_dipole_vec

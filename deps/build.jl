paths_file = "$(Pkg.dir("BSR"))/src/paths.jl"

if !isfile(paths_file)
    bsr = try
        ENV["BSR"]
    catch
        error("Did not find BSR environment variables. Please define it and rebuild BSR.")
    end

    isfile("$bsr/bsr_prep") || error("Could not find bsr_prep exe in $bsr")

    println("Found BSR at $bsr")

    open(paths_file, "w") do file
        write(file, """bsr = \"$bsr\"
    """)
    end
end

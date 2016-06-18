using Lumberjack

function build_args(kwargs)
    map(kwargs) do kv
        "$(kv[1])=$(kv[2])"
    end
end

macro bsr_exe(exe)
    exe_str = string(exe)
    @eval begin
        function ($exe)(args...; kwargs...)
            exe = string(bsr, "/", $exe_str)
            cmd = `$exe $args $(build_args(kwargs))`
            info("Executing $cmd")
            run(cmd)
            info("Finished executing $cmd")            
        end
        export $exe
    end
end

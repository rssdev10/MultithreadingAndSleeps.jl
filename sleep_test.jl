using Dates

log(str) = "$(Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")): $(str)"

function test_runner(func, titles, n)
    @info log("Running tasks for $titles")
    tasks = [@task func() for _ in 1:n]

    schedule.(tasks)

    @info log("Waiting for completion")
    wait.(tasks)

    @info log("Done")
end

function test_spawn_runner(func, title, n)
    @info log("Running tasks for $title")
    @sync for i in 1:n
        Threads.@spawn begin
            func()
            @info "task $(title)/$(i) completed"
        end
    end
    @info log("Done")
end


N = 10
@info log("Actual threads: $(Threads.nthreads()), Requested tasks: $N")

using PyCall
tm = pyimport("time")

# Require JULIA_COPY_STACKS=1
using JavaCall
JavaCall.init(["-Xmx128M"])
thread = @jimport java.lang.Thread


for func in [
    test_runner,
    test_spawn_runner
]
    @info string("Testing:", func)

    # test 1. Pure Julia sleep()
    @time func("Julia", N) do
        sleep(1)
    end

    # test 2. PyCall
    @time func("PyCall", N) do
        tm.sleep(1)
    end

    # test 3. JavaCall
    @time func("JavaCall", N) do
        jcall(thread, "sleep", Nothing, (jlong,), 1000)
    end
end

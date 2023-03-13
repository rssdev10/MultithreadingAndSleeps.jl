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

function test_spawn_runner(func, titles, n)
    @info log("Running tasks for $titles")
    @sync for _ in 1:n
        Threads.@spawn func()
    end
    @info log("Done")
end


N = 10
@info log("Actual threads: $(Threads.nthreads()), Requested tasks: $N")

using PyCall
tm = pyimport("time")


for func in [
    test_runner,
    test_spawn_runner
]
    @info string("Testing:", func)

    # test 1. Pure Julia sleep()
    @time func(() -> sleep(1), "Julia", N)

    # test 2. PyCall
    @time func(() -> tm.sleep(1), "PyCall", N)
end

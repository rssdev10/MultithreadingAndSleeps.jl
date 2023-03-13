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

N = 10
@info log("Actual threads: $(Threads.nthreads()), Requested tasks: $N")

# test 1. Pure Julia sleep()
@time test_runner(() -> sleep(1), "Julia", N)

# test 2. PyCall
using PyCall
tm = pyimport("time")
@time test_runner(() -> tm.sleep(1), "PyCall", N)

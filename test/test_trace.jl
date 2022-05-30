using NahaJuliaLib
using Logging
using VectorLogging


@testset "test trace" begin
    logger = VectorLogger()

    @trace trace_f1 f1(a, b::Int, c) = a + b + c
    trace_f1 = true
    with_logger(logger) do
        f1(1, 2, 3)
    end
    @test length(logger.log) == 2
    @test logger.log[1].message == "Trace enter"
    @test logger.log[1].keys isa AbstractDict
    # @test logger.log[1].keys[:fcall] == "(f1)(1, 2, 3)"    # FAILS
    @test logger.log[2].message == "Trace exit"
    @test logger.log[2].keys[:result] == 6
    @test logger.log[1].keys[:id] == 1
    @test logger.log[1].keys[:id] == logger.log[2].keys[:id]

    @trace trace_f2 f2(a; b=0, c=0) = a + b + c
    trace_f2 = true
    with_logger(logger) do
        f2(1; b=2, c=3)
    end
    @test length(logger.log) == 4
    @test logger.log[3].message == "Trace enter"
    # @test logger.log[1].keys[:fcall] == "(f2)(1; b = 2, c = 3)"    # FAILS
    @test logger.log[4].message == "Trace exit"
    @test logger.log[4].keys[:result] == 6
    @test length(logger.log) == 4
    @test logger.log[3].keys[:id] == 2
    @test logger.log[3].keys[:id] == logger.log[4].keys[:id]
end


trace_hanoi = false

@trace(trace_hanoi,
       function hanoi(from, to, other, count)
           if count == 0
               return nothing
           else
               hanoi(from, other, to, count - 1)
               println("move 1 from $from to $to")
               hanoi(other, to, from, count - 1)
               return (from, to)   # arbitrary result to show
           end
       end
       )

const SHOWN_HANOI_TRACE = """(hanoi)(a, b, c, 4) => (:a, :b)
  (hanoi)(a, c, b, 3) => (:a, :c)
    (hanoi)(a, b, c, 2) => (:a, :b)
      (hanoi)(a, c, b, 1) => (:a, :c)
        (hanoi)(a, b, c, 0) => nothing
        (hanoi)(b, c, a, 0) => nothing
      (hanoi)(c, b, a, 1) => (:c, :b)
        (hanoi)(c, a, b, 0) => nothing
        (hanoi)(a, b, c, 0) => nothing
    (hanoi)(b, c, a, 2) => (:b, :c)
      (hanoi)(b, a, c, 1) => (:b, :a)
        (hanoi)(b, c, a, 0) => nothing
        (hanoi)(c, a, b, 0) => nothing
      (hanoi)(a, c, b, 1) => (:a, :c)
        (hanoi)(a, b, c, 0) => nothing
        (hanoi)(b, c, a, 0) => nothing
  (hanoi)(c, b, a, 3) => (:c, :b)
    (hanoi)(c, a, b, 2) => (:c, :a)
      (hanoi)(c, b, a, 1) => (:c, :b)
        (hanoi)(c, a, b, 0) => nothing
        (hanoi)(a, b, c, 0) => nothing
      (hanoi)(b, a, c, 1) => (:b, :a)
        (hanoi)(b, c, a, 0) => nothing
        (hanoi)(c, a, b, 0) => nothing
    (hanoi)(a, b, c, 2) => (:a, :b)
      (hanoi)(a, c, b, 1) => (:a, :c)
        (hanoi)(a, b, c, 0) => nothing
        (hanoi)(b, c, a, 0) => nothing
      (hanoi)(c, b, a, 1) => (:c, :b)
        (hanoi)(c, a, b, 0) => nothing
        (hanoi)(a, b, c, 0) => nothing
"""

@testset "test trace analasys" begin
    logger = VectorLogger()
    old = trace_hanoi
    try
        global trace_hanoi = true
        with_logger(logger) do
            hanoi(:a, :b, :c, 4)
        end
        traces = analyze_traces(logger)
        @test length(traces) == 1
        out = IOBuffer()
        show_trace(out, traces[1])
        @test String(take!(out)) == SHOWN_HANOI_TRACE
    finally
        global trace_hanoi = old
    end
end


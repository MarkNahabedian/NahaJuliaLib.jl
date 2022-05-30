using DataStructures
using VectorLogging

export TraceRecord, analyze_traces, show_trace


mutable struct TraceRecord
    enter
    exit
    parent::Union{Nothing, TraceRecord}
    children # ::Tuple{TraceRecord}
end


istrace(le::VectorLogging.LogEntry) =
    le._module == NahaJuliaLib &&
    le.group == :trace

istraceenter(le::VectorLogging.LogEntry) =
    le.message == TRACE_ENTER

istraceexit(le::VectorLogging.LogEntry) =
    le.message == TRACE_EXIT

function sametrace(le1::VectorLogging.LogEntry,
                   le2::VectorLogging.LogEntry)
    le1.keys[:id] == le2.keys[:id]
end

tracethread(le::VectorLogging.LogEntry) = le.keys[:threadid]


struct StackEntry
    enter
    children

    StackEntry(enter) =
        new(enter, Vector{TraceRecord}())
end

"""
    analyze_traces(log::VectorLogger)
Given a log containinig log records produced by `@trace`, return a
vector of `TraceRecord`s.  Each of those `TraceRecord`s is the root of
a tree of `TraceRecord`s that represent the call tree.

Use `show_trace` to print the call hierarchy in a human readable form.
"""
function analyze_traces(log::VectorLogger)::Vector{TraceRecord}
    result = Vector{TraceRecord}()
    # stacks is indexed by the threadid of a log entry:
    stacks = Dict{Int, Stack{StackEntry}}()
    function getstack(threadid)
        if haskey(stacks, threadid)
            stacks[threadid]
        else
            stack = Stack{StackEntry}()
            stacks[threadid] = stack
            stack
        end
    end
    for le in log.log
        if !istrace(le)
            continue
        end
        stack = getstack(tracethread(le))
        if istraceenter(le)
            push!(stack, StackEntry(le))
        elseif istraceexit(le)
            # If a traced function is thrown from intentionally or due
            # to an error, that function's exit won't be logged.
            #
            # Trace IDs are monotonically increasing, so the closer a
            # frame is to the top of the stack, the greater its ID
            # when compared to lower frames in the same dynamic
            # context.
            #
            # This means that when we see an "exit" entry, we must
            # construct a TraceRecord for each "enter" entry on the
            # stack until and including the one with the same traceid
            # as the "exit".
            while true
                top = pop!(stack)
                match = le.keys[:id] == top.enter.keys[:id]
                new_tr = TraceRecord(top.enter,
                                     match ? le : :nothing,
                                     nothing,
                                     Tuple(top.children))
                for child in new_tr.children
                    child.parent = new_tr
                end
                if isempty(stack)
                    push!(result, new_tr)
                else
                    push!(first(stack).children, new_tr)
                end
                if match
                    break
                end
            end
        end
    end
    result
end


"""
    show_trace(trace::TraceRecord)
Print the specified `TraceRecord` hierarchy in a human readable form.
"""
show_trace(trace::TraceRecord) = show_trace(Base.stdout, trace)

function show_trace(io::IO, trace::TraceRecord)
    function st(trace, level)
        println(io, repeat("  ", level),
                trace.enter.keys[:fcall],
                if trace.exit == nothing
                    ""
                else
                    string(" => ", trace.exit.keys[:result])
                end
                )
        for c in trace.children
            st(c, level + 1)
        end
    end
    st(trace, 0)
end


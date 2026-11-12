using Combinatorics
using DataFrames
using Random

function generate_bus_configurations(
    num_GFL::Int,
    starting_GFM::Vector{Int},
    X::Int;
    seed=nothing
)
    all_buses = collect(30:39)
    required_SG = [35, 39]

    # Check that starting GFM buses are valid
    if !all(b -> b in all_buses, starting_GFM)
        error("Starting GFM buses must be between 30 and 39.")
    end

    if length(unique(starting_GFM)) != length(starting_GFM)
        error("Starting GFM buses must not contain duplicates.")
    end

    if !isempty(intersect(starting_GFM, required_SG))
        error("Buses 35 and 39 must remain SG.")
    end

    # Identify buses eligible to become GFL
    eligible_GFL = setdiff(all_buses, starting_GFM, required_SG)

    if num_GFL < 0 || num_GFL > length(eligible_GFL)
        error("Invalid number of GFL buses.")
    end

    # Enumerate all possible GFL combinations
    GFL_combinations = collect(combinations(eligible_GFL, num_GFL))

    # Build DataFrame containing all configurations
    df = DataFrame(
        SG_BUSES = Vector{Int}[],
        GFM_BUSES = Vector{Int}[],
        GFL_BUSES = Vector{Int}[]
    )

    for GFL in GFL_combinations
        SG = sort(setdiff(all_buses, starting_GFM, GFL))

        push!(df, (
            SG,
            sort(copy(starting_GFM)),
            collect(GFL)
        ))
    end

    # Check requested sample size
    if X < 0 || X > nrow(df)
        error("X must be between 0 and $(nrow(df)).")
    end

    # Randomly select X unique configurations
    rng = isnothing(seed) ? Random.default_rng() : MersenneTwister(seed)
    selected_indices = randperm(rng, nrow(df))[1:X]

    selected_df = df[selected_indices, :]

    return df, selected_df
end

function print_bus_configurations(df::DataFrame)

    for (i, row) in enumerate(eachrow(df))

        println("# Configuration $i")
        println("const SG_BUSES  = $(row.SG_BUSES)")
        println("const GFM_BUSES = $(row.GFM_BUSES)")
        println("const GFL_BUSES = $(row.GFL_BUSES)")
        println()

    end
end

all_configs, selected_configs = generate_bus_configurations(
    4,          # Number of GFL buses
    [31, 36],   # Starting GFM buses
    5;          # Randomly select 5 configurations
    seed=42     # Optional: reproducible random selection
)

print_bus_configurations(selected_configs)
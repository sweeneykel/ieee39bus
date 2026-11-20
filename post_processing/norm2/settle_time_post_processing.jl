function combine_distance_epsilon(df::DataFrame, independent_var::String, changing_param_summary, epsilon_value)

    # Combined title and simulation information
    plot_title = "Settling Time (ε = $(epsilon_value))\n$(changing_param_summary)"

    # Initialize plot
    p = plot(
        xlabel = independent_var,
        ylabel = "Time [s]",
        title = plot_title,
        size = (1100, 900),
        guidefontsize = 10,  # Axis label size
        tickfontsize = 8,    # Axis tick size
        titlefontsize = 12,
        titlelocation = :center,
        ylims = (2.00, 10.50),
        grid = true,
        legend = :topright,
        legendfontsize = 8,
        legendmarkersize = 3,
        left_margin = 5Plots.mm,
        top_margin = 5Plots.mm,
        right_margin = 5Plots.mm
    )

    colors = palette(:tab10)

    # Loop through each dataset
    for (i, row) in enumerate(eachrow(df))

        data = CSV.read(row.sim_res, DataFrame)
        sort!(data, :independent_variable)

        scatter!(
            p,
            data.independent_variable,
            data.settling_time;
            marker = :circle,
            markersize = 5,
            markercolor = colors[mod1(i, length(colors))],
            label = row.sim_nm
        )
    end

    display(p)
    return p
end

simulation_results = ["settle_time_x_GFL_KW (3 GLF BUS).csv",
                      "settle_time_x_GFL_KW (4 GLF BUS).csv",
                      "settle_time_x_GFL_KW (5 GLF BUS).csv",
                      "settle_time_x_GFL_KW (6 GLF BUS).csv"]

simulation_name = ["3 GFL",
                   "4 GFL",
                   "5 GFL",
                   "6 GFL"]

df = DataFrame(
                sim_res = simulation_results, 
                sim_nm = simulation_name)

changing_param_sum = """
            Bus 35, t=0.50s: ΔP=+200.0 MW, ΔQ=+10.0 MVAr
            PLL Kp: 0.03 | PLL Ki: 1.5
            """

dist_ε = 0.0009

p = combine_distance_epsilon(
    df,
    "GFL KW",
    changing_param_sum,
    dist_ε
)

savefig(p, joinpath(pwd(), "settle_time_x_GFL_KW.png"))
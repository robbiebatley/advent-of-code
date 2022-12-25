# NTuples  used to store counts or robots/resources
# Position:
# - 1 is ore
# - 2 is clay
# - 3 is obsidian
# - 4 is geode
const ore = (1, 0, 0, 0)
const clay = (0, 1, 0, 0)
const obs = (0, 0, 1, 0)
const geo = (0, 0, 0, 1)

parse_blueprint = function(blueprint)
    r = r"Blueprint (?<id>\d+): Each ore robot costs (?<ore1>\d+) ore. Each clay robot costs (?<clay1>\d+) ore. Each obsidian robot costs (?<obs1>\d+) ore and (?<obs2>\d+) clay. Each geode robot costs (?<geo1>\d+) ore and (?<geo3>\d+) obsidian."
    id, ore1, clay1, obs1, obs2, geo1, geo3 = match(r, blueprint)
    id = parse(Int64, id)
    # Order is important - will search paths which greedily purchase higher robots first
    robot_cost = Dict(
        geo => (parse(Int64, geo1), 0,  parse(Int64, geo3), 0),
        obs => (parse(Int64, obs1), parse(Int64, obs2), 0, 0),
        clay => (parse(Int64, clay1), 0, 0, 0),
        ore => (parse(Int64, ore1), 0, 0, 0),
    )
    id, robot_cost    
end

struct State
    turn::Int64
    robots::NTuple{4, Int64} # Number of robots of each type
    resources::NTuple{4, Int64} # Current number of each resource
    next_robot::NTuple{4, Int64} # Next robot to produce
end

"""Update state"""
update_state = function(s::State)
    resources = s.resources .+ s.robots
    State(s.turn + 1, s.robots, resources, s.next_robot)
end

"""Select next robot"""
next_robots = function(robots, max_ore, max_clay, max_obs)
    out = Vector{NTuple{4, Int64}}()
    sizehint!(out, 4)
    if robots[1] < max_ore
        push!(out, ore)
    end
    if robots[2] < max_clay
        push!(out, clay)
    end
    # Need at least 1 clay robot to make obs robots
    if robots[3] < max_obs && robots[2] > 0
        push!(out, obs)
    end
    # Need at least 1 obs robot to make geo robots
    if robots[3] > 0
        push!(out, geo)
    end
    out
end

best_case = function(s::State, robot_cost, max_turn)
    time_left = max_turn - s.turn
    max_obs = s.resources[3] + s.robots[3] * time_left + div(time_left * (time_left), 2)
    max_new_geo = div(max_obs, robot_cost[geo][3])
    achieveable = s.resources[4] + s.robots[4] * time_left
    if max_new_geo >= time_left
        return achieveable + div(time_left * (time_left - 1), 2)
    end
    achieveable + div(max_new_geo * (max_new_geo - 1), 2) + (time_left - max_new_geo) * max_new_geo
end


"""Check if we can purchase robot yet"""
robot_available = function(s::State, robot_cost)
    cost = robot_cost[s.next_robot]
    all(cost .<= s.resources)
end

quality_level = function(robot_cost, max_turns)

    final_geode = 0
    queue = [
        State(0, (1, 0, 0, 0), (0, 0, 0, 0), ore),
        State(0, (1, 0, 0, 0), (0, 0, 0, 0), clay)
    ]
    seen = Set{State}()

    # Preallocate a decent chunk of memory
    sizehint!(queue, 100_000)
    sizehint!(seen, 100_000)

    # Only continue purchasing if we can spend production
    max_ore = maximum([v[1] for v in values(robot_cost)])
    max_clay = maximum([v[2] for v in values(robot_cost)])
    max_obs = maximum([v[3] for v in values(robot_cost)])

    while length(queue) > 0
        state = pop!(queue)
        
        if state in seen
            continue
        end
        push!(seen, state)

        if best_case(state, robot_cost, max_turns) <= final_geode
            continue
        end

        while state.turn < max_turns
            if !robot_available(state, robot_cost)
                state = update_state(state)
                continue
            end
            turn = state.turn + 1
            robots = state.robots .+ state.next_robot            
            resources = state.resources .+ state.robots .- robot_cost[state.next_robot]
            branches = next_robots(robots, max_ore, max_clay, max_obs)
            for robot in branches
                push!(queue, State(turn, robots, resources, robot))
            end
            break            
        end
        # Append final resources
        if state.turn == max_turns && state.resources[4] > final_geode
            final_geode = state.resources[4]
        end
    end

    final_geode
end

# input = [
#     "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.",
#     "Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.",
# ]

# Part 1
input = readlines("day19/input.txt")
blueprints = [parse_blueprint(l) for l in input]
quality_levels = sum([id * quality_level(robot_cost, 24) for (id, robot_cost) in blueprints])

println("Part 1: $quality_levels")

# Part 2
geodes = [quality_level(robot_cost, 32) for (id, robot_cost) in blueprints[1:3]]
println("Part 2: $(prod(geodes))")
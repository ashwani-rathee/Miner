module Miner

const ASSET_DIR = realpath(joinpath(@__DIR__, "../assets"))

using GLMakie
using GLMakie.GLFW
using CoherentNoise
using GeometryBasics
using Colors
using FixedPointNumbers
using FileIO
using Sockets
using Distances
using Printf
using JSON

world_changes = Dict()

world_changelocs = []
world_changeblocks = []
world_changemsg = 1
include("world_manager.jl")
include("block_manager.jl")
include("player_controller.jl")

export start_game

stringify(x, fmt="%.2f") = Printf.format(Printf.Format(fmt), x)

obj_markers = Dict(stone => (16, 6),
    water => (4, 10),
    grass => (14, 1),
    dirt => (16, 1),
    wood => (15, 5),
    leaves => (16, 15),
    bedrock => (4, 1),
)

function start_game()
    @info "Starting Game!"
    Makie.set_theme!(; ssao=true)
    scene = Scene(; backgroundcolor=:lightblue)
    pc = PlayerController(scene)

    empty!(world_changes)
    world_changelocs = []
    world_changeblocks = []

    subscene = Scene(scene)
    campixel!(subscene)
    gap = 3 * (1 / size(scene)[1])
    line = 10 * (1 / size(scene)[1])
    mid = Point2f(0.5, 0.5)
    crosshair = Point2f[
        mid.+Point2f(gap, 0), mid.+Point2f(gap + line, 0),
        mid.-Point2f(gap, 0), mid.-Point2f(gap + line, 0),
        mid.+Point2f(0, gap), mid.+Point2f(0, gap + line),
        mid.-Point2f(0, gap), mid.-Point2f(0, gap + line),
    ]
    linesegments!(subscene, crosshair; color=(:red, 0.5), inspectable=false, linewidth=2, space=:relative)

    # Read JSON file
    config = JSON.parsefile("config.json")

    # Extract values
    ip_address = IPv4(config["ip_address"])
    port = config["port"]
    key = config["key"]
    player_name = config["player_name"]

    interval = 1
    server = Sockets.UDPSocket()
    bind(server, ip"0.0.0.0", port)

    message = string(key, ":ClientHello:", player_name)
    send(server, ip_address, port, message)
    println("Sent message to server: ", message)

    # Channel to communicate received data
    channel = Channel{String}(32)

    # Function to handle receiving data in a separate thread
    function receive_data(server, channel)
        #@show "Running recv loop.."
        while true
            data = try
                recv(server)
            catch
                nothing
            end
            if data !== nothing
                ack = String(data)
                # @show "message:" ack
                put!(channel, ack)  # Push data to channel
            end

            if (!isempty(channel))
                value = take!(channel)
                parts = split(value, ',')
                x, y, z = parse.(Float64, parts[end-2:end])
                positionPlayer[] = Point3f0(x, y, z)
            end
            sleep(0.001)
        end
    end

    # Start receiving data in a separate thread
    thread = Threads.@spawn receive_data(server, channel)


    c = cameracontrols(scene)
    c.eyeposition[] = (5, surface_height(0, 0) + 3, 5)
    c.lookat[] = Vec3f(6, surface_height(0, 0) + 3, 6)
    c.upvector[] = (1, 1, 1)
    update_cam!(scene)


    prev_loc = c.eyeposition[]
    curr_loc = c.eyeposition[]

    framerate = Observable("Frame Rate: 10")
    text!(subscene, Point(15, 45), text=framerate)

    camloc = Observable("Curr Loc: [0,0,0]")
    text!(subscene, Point(15, 30), text=camloc)

    locMouse = Observable("Mouse CLoc: [0,0,0]")
    text!(subscene, Point(15, 15), text=locMouse)

    currBlock = Observable(BlockType(2))
    txt = Observable("Item in hand: stone")
    text!(subscene, Point(15, 120), text=txt)
    cor1, cor2 = obj_markers[currBlock[]]
    node = Observable(rotr90(tex[(cor1-1)*16+1:(cor1-1)*16+16, (cor2-1)*16+1:(cor2-1)*16+16]))
    image!(subscene, 15 .. 65, 65 .. 115, node)


    positionsAll = [Observable(Vector{GLMakie.Point3f0}([])) for i in 1:17]
    for x in -100:1:100, y in -16:1:32, z in -100:1:100
        push!(positionsAll[Int(block_state(x, y, z))][], GLMakie.Point3f0(x, y, z))
    end

    positionPlayer = Observable(GLMakie.Point3f0(30.0, 30.0, 30.0))
    meshscatter!(scene, positionPlayer; markersize=1, marker=return_mesh(BlockType(1)))

    for (idx, i) in enumerate(positionsAll)
        marker = return_mesh(BlockType(idx))
        if (idx == 1)
            a = meshscatter!(scene, i; markersize=1, marker=marker, color=(:grey, 0))
        elseif (idx == 9)
            a = meshscatter!(scene, i; markersize=1, marker=marker, color=(:white, 0.8))
        elseif (idx in collect(10:16))
            i[] = repeat(i[] .- Point3f0(-0.5, -0.5, -0.5), 2)
            uv = scatter_cases[idx]
            up = qrotation(Vec3f(0, 1, 0), 0.5pi)
        else
            a = meshscatter!(scene, i; markersize=1, marker=marker, color=tex)
        end
    end

    # for block adding and breaking
    on(events(scene).mousebutton) do button
        if (button.button == Makie.Mouse.left && button.action == Makie.Mouse.press)
            p, idx = pick(scene, round.(Int, size(scene) ./ 2))
            isnothing(p) && return

            locMouse[] = string("Mouse CLoc: ", round.(Int, p.positions[][idx]))
            loc = p.positions[][idx]

            a = cameracontrols(scene).eyeposition[]
            a = Point3f0(a[1], a[2], a[3])
            b = adjacent_blocks(p.positions[][idx])
            order = distance(a, b)

            buildable = nothing

            for i in order
                if (block_state(Int(i[1]), Int(i[2]), Int(i[3])) == BlockType(1) && i ∉ world_changelocs)
                    buildable = i
                    break
                end
            end

            a = currBlock[]
            if (!isnothing(buildable))
                world_changes[buildable] = a
                push!(positionsAll[Int(a)][], buildable)
                push!(world_changelocs, buildable)
                push!(world_changeblocks, a)
            end
            notify(positionsAll[Int(a)])
        elseif (button.button == Makie.Mouse.right && button.action == Makie.Mouse.press)
            p, idx = pick(scene, round.(Int, size(scene) ./ 2))
            isnothing(p) && return

            locMouse[] = string("Mouse CLoc: ", round.(Int, p.positions[][idx]))
            loc = p.positions[][idx]
            if (block_state(round(Int, loc[1]), round(Int, loc[2]), round(Int, loc[3])) != bedrock)
                if (p.positions[][idx] in world_changelocs)

                    idx1 = findfirst(x -> x == p.positions[][idx], world_changelocs)
                    deleteat!(world_changelocs, idx1)
                    deleteat!(world_changeblocks, idx1)
                end
                world_changes[loc] = air
                deleteat!(p.positions[], idx)
                notify(p.positions)
            end
        end
    end

    on(events(scene).scroll, priority=100) do event
        if (event[2] > 0)
            # go to left
            if (Int(currBlock[]) > 2)
                currBlock[] = BlockType(Int(currBlock[]) - 1)
                txt[] = string("Item in hand: ", currBlock[])
            end
        else
            # go to right
            if (Int(currBlock[]) < 8)
                currBlock[] = BlockType(Int(currBlock[]) + 1)
                txt[] = string("Item in hand: ", currBlock[])
            end
        end

        cor1, cor2 = obj_markers[currBlock[]]
        node[] = rotr90(tex[(cor1-1)*16+1:(cor1-1)*16+16, (cor2-1)*16+1:(cor2-1)*16+16])
        return Consume(false)
    end

    screen = GLMakie.Screen(scene; focus_on_show=true, float=true, ssao=true, start_renderloop=false)
    glscreen = screen.glscreen

    on(events(scene).keyboardbutton) do button
        if button.key == Makie.Keyboard.escape
            GLFW.make_windowed!(glscreen)
            GLFW.SetInputMode(glscreen, GLFW.CURSOR, GLFW.CURSOR_NORMAL)
            GLFW.SetWindowAttrib(glscreen, GLFW.DECORATED, true)
            return
        end
        if (button.key == Makie.Keyboard._1 && button.action == Makie.Keyboard.press)
            if (Int(currBlock[]) > 2)
                currBlock[] = BlockType(Int(currBlock[]) - 1)
                txt[] = string(currBlock[])
            end
        elseif (button.key == Makie.Keyboard._2 && button.action == Makie.Keyboard.press)
            if (Int(currBlock[]) < 8)
                currBlock[] = BlockType(Int(currBlock[]) + 1)
                txt[] = string(currBlock[])
            end
        end
    end

    GLFW.SetInputMode(glscreen, GLFW.CURSOR, GLFW.CURSOR_DISABLED)

    # GLFW.SetKeyCallback(glscreen, esc_callback)
    # GLFW.make_fullscreen!(glscreen)
    cam_controls = cameracontrols(scene)
    last_time = time()
    task = @async begin
        while isopen(screen)
            try
                GLMakie.pollevents(screen)
                yield()
                timestep = time() - last_time
                last_time = time()
                prev_loc = curr_loc
                move_cam!(scene, pc, timestep)
                update_cam!(scene, pc)
                curr_loc = cam_controls.eyeposition[]
                d = euclidean(prev_loc, curr_loc)
                if (d > 0.01)
                    @show d
                    msg = join(map(x -> stringify(x), curr_loc), ",")
                    send(server, ip_address, port, string(key, ":loc:", msg))

                    #println("Sent message to server: ", msg)
                end
                time_per_frame = 1.0 / 30
                t = time_ns()
                GLMakie.render_frame(screen)
                GLFW.SwapBuffers(glscreen)
                t_elapsed = (time_ns() - t) / 1e9
                diff = time_per_frame - t_elapsed
                if diff > 0.001 # can't sleep less than 0.001
                    sleep(diff)
                else # if we don't sleep, we still need to yield explicitely to other tasks
                    yield()
                end

                framerate[] = string("Frame Rate: ", round(Int, 1 / t_elapsed))
                camloc[] = string("Current Loc: ", cam_controls.eyeposition[])
            catch e
                @warn "Error in renderloop" exception = (e, catch_backtrace())
                close(screen)
            end
        end

        send(server, ip_address, port, string(key, ":ClientBye:", player_name))

        close(screen)
    end
    Base.errormonitor(task)

    return screen
end

end # module Miner

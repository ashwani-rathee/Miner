module Miner

const ASSET_DIR = realpath(joinpath(@__DIR__, "../assets"))

using GLMakie
using GLMakie.GLFW
using CoherentNoise
using GeometryBasics
using Colors
using FixedPointNumbers
using FileIO

include("world_manager.jl")
include("block_manager.jl")
include("player_controller.jl")

export start_game

function start_game()
    @info "Starting Game!"
    Makie.set_theme!(; ssao=true)
    scene = Scene(; backgroundcolor=:lightblue)
    pc = PlayerController(scene)

    subscene = Scene(scene)
    campixel!(subscene)
    gap = 3 * (1 / size(scene)[1])
    line = 10 * (1 / size(scene)[1])
    mid = Point2f(0.5, 0.5)
    crosshair = Point2f[
        mid .+ Point2f(gap, 0), mid .+ Point2f(gap + line, 0),
        mid .- Point2f(gap, 0), mid .- Point2f(gap + line, 0),
        mid .+ Point2f(0, gap), mid .+ Point2f(0, gap + line),
        mid .- Point2f(0, gap), mid .- Point2f(0, gap + line),
    ]
    linesegments!(subscene, crosshair; color=(:red, 0.5), inspectable=false, linewidth=2, space=:relative)

    world_changelocs = []
    world_changeblocks = []

    c = cameracontrols(scene)
    c.eyeposition[] = (5, surface_height(0, 0) + 3, 5)
    c.lookat[] = Vec3f(6, surface_height(0, 0) + 3, 6)
    c.upvector[] = (1, 1, 1)
    update_cam!(scene)

    currBlock = Observable(BlockType(2))
    text!(subscene, Point(10, 10), text="Block In-Hand:")

    txt = Observable("stone")
    text!(subscene, Point(120, 10), text=txt)

    framerate = Observable("10 fps")
    text!(subscene, Point(170, 10), text=framerate)

    camloc = Observable("Current Loc: [0,0,0]")
    text!(subscene, Point(220, 10), text=camloc)

    locMouse = Observable("Mouse click on object at: [0,0,0]")
    text!(subscene, Point(10, 30), text=locMouse)

    positionsAll = [Observable(Vector{GLMakie.Point3f0}([])) for i in 1:17]
    for x in -32:1:32, y in -16:1:32, z in -32:1:32
        push!(positionsAll[Int(block_state(x, y, z))][], GLMakie.Point3f0(x, y, z))
    end

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

            locMouse[] = string("Mouse click on object at: ", round.(Int, p.positions[][idx]))
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
                push!(positionsAll[Int(a)][], buildable)
                push!(world_changelocs, buildable)
                push!(world_changeblocks, a)
            end

            notify(positionsAll[Int(a)])
        elseif (button.button == Makie.Mouse.right && button.action == Makie.Mouse.press)
            p, idx = pick(scene, round.(Int, size(scene) ./ 2))
            isnothing(p) && return

            locMouse[] = string("Mouse click on object at: ", round.(Int, p.positions[][idx]))
            loc = p.positions[][idx]
            if (p.positions[][idx] in world_changelocs)
                idx1 = findfirst(x -> x == p.positions[][idx], world_changelocs)
                deleteat!(world_changelocs, idx1)
                deleteat!(world_changeblocks, idx1)
            end
            deleteat!(p.positions[], idx)
            notify(p.positions)
        end
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
    GLFW.make_fullscreen!(glscreen)
    cam_controls = cameracontrols(scene)
    last_time = time()
    task = @async begin
        while isopen(screen)
            try
                GLMakie.pollevents(screen)
                yield()
                timestep = time() - last_time
                last_time = time()
                move_cam!(scene, pc, timestep)
                update_cam!(scene, pc)
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
                framerate[] = string(round(Int, 1 / t_elapsed), " fps")
                camloc[] = string("Current Loc:", round.(Int, cam_controls.eyeposition[]))
            catch e
                @warn "Error in renderloop" exception=(e, catch_backtrace())
                close(screen)
            end
        end
        close(screen)
    end
    Base.errormonitor(task)

    return screen
end

end # module Miner

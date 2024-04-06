const tex = let
    tex = load(joinpath(ASSET_DIR, "texture.png"))
    replace!(tex, tex[1, 1] => RGBA{N0f8}(0, 0, 0, 0))
    collect(tex)
end


function return_mesh(block::BlockType)    
    # @info Int(block)
    ntex = 16 # textures packed into quads in the texture 
    if (block == BlockType(4))
        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        x = Rect3f((0.0f0, 0.0f0, 0.0f0), (1.0f0, 1.0f0, 1.0f0))
        # side face
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f(0, (1 / ntex)), Vec2f[ (1, 0), (0, 0), (0, 1), (1, 1)])
        # bottom face
        mesh.uv[5:8] = map(x-> (x ./ ntex) .+ Vec2f(0, (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        # side face
        mesh.uv[9:12] = map(x-> (x ./ ntex) .+ Vec2f(0, (1 / ntex)), Vec2f[  (0, 0), (0, 1), (1, 1), (1, 0)])
        # side face :correct
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f(0, (1 / ntex)), Vec2f[(0, 1), (1, 1), (1, 0), (0, 0)])
        # side face
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f(0, (1 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        # top face
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f(0, (2 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        return mesh
    elseif (block == BlockType(2))
        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        # x = Rect3f((0.0f0, 0.0f0, 0.0f0), (1.0f0, 1.0f0, 1.0f0))
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f((5 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[5:8] = map(x -> (x ./ ntex) .+ Vec2f((5 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[9:12] = map(x -> (x ./ ntex) .+ Vec2f((5 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f((5 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f((5 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f((5 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        return mesh
    elseif (block == BlockType(5))
        # grass
        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        x = Rect3f((0.0f0, 0.0f0, 0.0f0), (1.0f0, 1.0f0, 1.0f0))
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f((6 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[5:8] = map(x -> (x ./ ntex) .+ Vec2f((6 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[9:12] = map(x -> (x ./ ntex) .+ Vec2f((6 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f((6 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f((6 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f((6 / ntex), (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        return mesh
    elseif (block == BlockType(7))
        # leaves
        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        offsetX = 14
        offsetY = 0
        x = Rect3f((0.0f0, 0.0f0, 0.0f0), (1.0f0, 1.0f0, 1.0f0))
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[5:8] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[9:12] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        return mesh
    elseif (block == BlockType(1))
        mesh = Rect3f(Vec3f(0), Vec3f(1))
        return mesh
    elseif (block == BlockType(3))
        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        offsetX = 9
        offsetY = 12
        x = Rect3f((0.0f0, 0.0f0, 0.0f0), (1.0f0, 1.0f0, 1.0f0))
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[5:8] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[9:12] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        return mesh
    elseif (block == BlockType(5))
        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        offsetX = 6
        offsetY = 0
        x = Rect3f((0.0f0, 0.0f0, 0.0f0), (1.0f0, 1.0f0, 1.0f0))
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[5:8] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[9:12] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        return mesh

    elseif (block == BlockType(6))
        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        # side face
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[ (1, 0), (0, 0), (0, 1), (1, 1)])
        # bottom face
        mesh.uv[5:8] = map(x-> (x ./ ntex) .+ Vec2f(4/16, (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        # side face
        mesh.uv[9:12] = map(x-> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[  (0, 0), (0, 1), (1, 1), (1, 0)])
        # side face :correct
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[(0, 1), (1, 1), (1, 0), (0, 0)])
        # side face
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        # top face
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (2 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        return mesh

    elseif (block == BlockType(8))

        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        offsetX = 0
        offsetY = 12
        x = Rect3f((0.0f0, 0.0f0, 0.0f0), (1.0f0, 1.0f0, 1.0f0))
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[5:8] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[9:12] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f((offsetX  / ntex), (offsetY  / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        return mesh
    elseif (block == BlockType(17))
        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        # side face
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[ (1, 0), (0, 0), (0, 1), (1, 1)])
        # bottom face
        mesh.uv[5:8] = map(x-> (x ./ ntex) .+ Vec2f(4/16, (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        # side face
        mesh.uv[9:12] = map(x-> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[  (0, 0), (0, 1), (1, 1), (1, 0)])
        # side face :correct
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[(0, 1), (1, 1), (1, 0), (0, 0)])
        # side face
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        # top face
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f(13/16, (0 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        return mesh
    elseif (block == BlockType(18))
        @show "Aaa"
        mesh = uv_normal_mesh(Rect3f(Vec{3}(0, 0, 0), Vec{3}(1, 2, 1)))
        # side face
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f(1/16, (14 / ntex)), Vec2f[ (1, 0), (0, 0), (0, 1), (1, 1)])
        # bottom face
        mesh.uv[5:8] = map(x-> (x ./ ntex) .+ Vec2f(1/16, (13 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        # side face
        mesh.uv[9:12] = map(x-> (x ./ ntex) .+ Vec2f(2/16, (14 / ntex)), Vec2f[  (0, 0), (0, 1), (1, 1), (1, 0)])
        # side face :correct
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f(3/16, (14 / ntex)), Vec2f[(0, 1), (1, 1), (1, 0), (0, 0)])
        # side face
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f(0/16, (14 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        # top face
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f(1/16, (15 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        return mesh
    
    elseif (Int(block) in collect(10:16))
        mesh = uv_normal_mesh(Rect3f(Vec3f(0), Vec3f(1)))
        # side face
        mesh.uv[1:4] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[ (1, 0), (0, 0), (0, 1), (1, 1)])
        # bottom face
        mesh.uv[5:8] = map(x-> (x ./ ntex) .+ Vec2f(4/16, (0 / ntex)), Vec2f[(1, 0), (0, 0), (0, 1), (1, 1)])
        # side face
        mesh.uv[9:12] = map(x-> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[  (0, 0), (0, 1), (1, 1), (1, 0)])
        # side face :correct
        mesh.uv[13:16] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[(0, 1), (1, 1), (1, 0), (0, 0)])
        # side face
        mesh.uv[17:20] = map(x -> (x ./ ntex) .+ Vec2f(4/16, (1 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        # top face
        mesh.uv[21:24] = map(x -> (x ./ ntex) .+ Vec2f(13/16, (0 / ntex)), Vec2f[(1, 1), (1, 0), (0, 0), (0, 1)])
        return mesh
    
    else
        mesh = Rect3f(Vec3f(0), Vec3f(1))
        return mesh
    end
end

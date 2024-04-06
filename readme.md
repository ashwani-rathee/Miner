# Miner.jl

Voxel World Simulator written using Makie's GLMakie backend in Julia

## Features:
- Uses GLMakie's GPU based rendering for fast rendering of large voxel worlds
- Uses Julia's multithreading for various tasks
- Utilizes Coherent Noise Library for generating terrain
- Can be used as testing ground for image processing and computer vision tasks
- Has a inbuilt music player using Channels and playing audio with WAV.jl

# Run by
```
using Pkg
Pkg.activate()
using Revise
Pkg.activate(".")
using Miner
start_game()
```
## Updates:

[![IMAGE ALT TEXT HERE](https://i.imgur.com/eeAaJuK.png)](https://youtu.be/S-uLTsE2wZg)

## References and Credits
- Player Controller Camera initially written by @ffreyer



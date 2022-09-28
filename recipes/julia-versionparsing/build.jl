#!/bin/env julia

using Pkg, UUIDs

const CONDA_PREFIX = ENV["PREFIX"]
const JULIA_DEPOT = DEPOT_PATH[1]
const BUILD_DEPOT = joinpath(CONDA_PREFIX, "share", "julia_build_depot")

# A simple adding like this may entail additional network activity
#Pkg.add("${name}")

# Add the local git repository that conda build cloned
uuid = UUID("${uuid}"); nothing # suppress output
spec = PackageSpec(
    name="${name}",
    uuid=uuid,
    path="${PREFIX}/share/julia/clones/${name}.jl",
)
Pkg.add(spec)


# Select certain folders
mkpath(BUILD_DEPOT)
const directories = ("packages", "artifacts", "clones")
for directory in directories
    try
        mv(joinpath(JULIA_DEPOT, directory), joinpath(BUILD_DEPOT, directory))
    catch err
        @warn "Could not move \$directory" err
    end
end


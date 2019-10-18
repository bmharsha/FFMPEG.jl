using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libz"], :libz),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/bmharsha/FFMPEG.jl/releases/download/v0.2.91"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.aarch64-linux-gnu.tar.gz", "32aad9068221742523582d8874739dd4b505b5c341e43b8110938aa4493893e0"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Zlib.v1.2.11.aarch64-linux-musl.tar.gz", "193be886c2f54efb231296e9317a4427632977e41a8816ebaa207d2b67e1f5ec"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Zlib.v1.2.11.arm-linux-gnueabihf.tar.gz", "15fbc9dd9e939ba19b3f907760d403bf0eec07c404176e55050ade1347ebcafb"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Zlib.v1.2.11.arm-linux-musleabihf.tar.gz", "2b694ebb2e38f016535522e80462b6de645c320bb831e288da6337c9ccb58e08"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.i686-linux-gnu.tar.gz", "b991962d36468e0b0c63915e2c241949ffdb65562dc67328677832821a9dcc9f"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Zlib.v1.2.11.i686-linux-musl.tar.gz", "4068972a80976a25b0bb2ab15553b73b196dce71f1780cebe50b7b1b2ca9c896"),
    Windows(:i686) => ("$bin_prefix/Zlib.v1.2.11.i686-w64-mingw32.tar.gz", "39a23fcc728f670ede4fb97207670286385faae8aee74faa42c0b4b87744b62d"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.powerpc64le-linux-gnu.tar.gz", "dcc55c8f6ed177b35d3b42780810f99cad3b1933745d890127b1f8a7feb5f4a5"),
    MacOS(:x86_64) => ("$bin_prefix/Zlib.v1.2.11.x86_64-apple-darwin14.tar.gz", "8c0f59d124bcb87e738164de4dbc1ee6aed05d8d6ff3b0f3deb05a4bbf13e89f"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.x86_64-linux-gnu.tar.gz", "e239076466dfa020e4e67db35d8ed25b4e547b062236a42914fdb06d053a7b12"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Zlib.v1.2.11.x86_64-linux-musl.tar.gz", "53e226afe9ea4bec87c0ddabe5babb080472ea1707bb4e09ec2b7ad1b610d2e7"),
    FreeBSD(:x86_64) => ("$bin_prefix/Zlib.v1.2.11.x86_64-unknown-freebsd11.1.tar.gz", "2762ecca88ee081b422dd0a6e866e8fdfa3cc72d5c743a441fe94307bd4cd118"),
    Windows(:x86_64) => ("$bin_prefix/Zlib.v1.2.11.x86_64-w64-mingw32.tar.gz", "e5839d332ac03dbc1deec3a64d723a9278b05e360cdbc3364cc991e1cb0b244f"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)

using BinaryProvider

# BinaryProvider support
const prefix = Prefix(joinpath(dirname(@__DIR__),"deps","usr"))
 
# We only care about libnettle, get it put into our `deps.jl` file:
libnettle = LibraryResult(joinpath(libdir(prefix), "libnettle"))
# We're also going to find `nettle-hash` and `nettle.pc` for completeness
nettlehash = ExecutableResult(joinpath(bindir(prefix), "nettle-hash"))
nettlepc = FileResult(joinpath(libdir(prefix), "pkgconfig", "nettle.pc"))

# This is where we download things from, for different platforms
const bin_prefix="https://github.com/staticfloat/NettleBuilder/releases/download/v3.3.3"
const download_info = Dict(
    :linuxaarch64 => ("$bin_prefix/nettle.aarch64-linux-gnu.tar.gz", "271c4897754eb353df60fd7ebe167eea8aeffc677f8982c2ef4b4fb5eb636475"),
    :linuxppc64le => ("$bin_prefix/nettle.powerpc64le-linux-gnu.tar.gz", "e38189ed6283e08831e2d2284eb67c720661d2a30fe86189dc0ba89125334e28"),
    :linuxarmv7l => ("$bin_prefix/nettle.arm-linux-gnueabihf.tar.gz", "e4ca07b459a134bd397a5fe8bd0e0b89156bbe5277f6d65a128155bbca6c1119"),
    :linux32 => ("$bin_prefix/nettle.i686-linux-gnu.tar.gz", "da842f30c32567c145b0cd550b15b602934e7664182b41bdc5256a8448d00932"),
    :linux64 => ("$bin_prefix/nettle.x86_64-linux-gnu.tar.gz", "c614be2e4e7a3b9e5b531bab70533935e14308e0092a6d786a7aad4d0f599f7a"),
    :mac64 => ("$bin_prefix/nettle.x86_64-apple-darwin14.tar.gz", "43ca1837baf37df895e5791d4da6c52030b47359b36c3b08bded041774b33ef8"),
    :win32 => ("$bin_prefix/nettle.i686-w64-mingw32.tar.gz", "5893dd0be244c31e653c8076dc414d7f06fa27aece910d12f1e976fb19fcfb98"),
    :win64 => ("$bin_prefix/nettle.x86_64-w64-mingw32.tar.gz", "9b47d73bf03e40c978f4757a7a67fce92a9c073deb68cf6b91ce2154ae5625c3"),
)
if platform_key() in keys(download_info)
    # First, check to see if we're all satisfied
    if any(!satisfied(p; verbose=true) for p in [libnettle, nettlehash, nettlepc])
        # Download and install libnettle
        url, tarball_hash = download_info[platform_key()]
        install(url, tarball_hash; prefix=prefix, force=true, verbose=true)
    end
    @write_deps_file libnettle nettlehash
else
    error("Your platform $(Sys.MACHINE) is not recognized, we cannot install Nettle!")
end



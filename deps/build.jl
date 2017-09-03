using BinDeps
using Compat
using BinaryProvider
# Include BinaryProvider's BinDeps integration
include(Pkg.dir("BinaryProvider", "src", "BinDepsIntegration.jl"))

@BinDeps.setup

nettle = library_dependency("nettle", aliases = ["libnettle","libnettle-4-6","libnettle-6-1","libnettle-6-2"])

# BinaryProvider support
const bin_prefix="https://github.com/staticfloat/NettleBuilder/releases/download/v3.3.3"
const downloads = Dict(
    "linuxaarch64" => ("$bin_prefix/nettle.aarch64-linux-gnu.tar.gz", "271c4897754eb353df60fd7ebe167eea8aeffc677f8982c2ef4b4fb5eb636475"),
    "linuxppc64le" => ("$bin_prefix/nettle.powerpc64le-linux-gnu.tar.gz", "e38189ed6283e08831e2d2284eb67c720661d2a30fe86189dc0ba89125334e28"),
    "linuxarmv7l" => ("$bin_prefix/nettle.arm-linux-gnueabihf.tar.gz", "e4ca07b459a134bd397a5fe8bd0e0b89156bbe5277f6d65a128155bbca6c1119"),
    "linux32" => ("$bin_prefix/nettle.i686-linux-gnu.tar.gz", "da842f30c32567c145b0cd550b15b602934e7664182b41bdc5256a8448d00932"),
    "linux64" => ("$bin_prefix/nettle.x86_64-linux-gnu.tar.gz", "c614be2e4e7a3b9e5b531bab70533935e14308e0092a6d786a7aad4d0f599f7a"),
    "mac64" => ("$bin_prefix/nettle.x86_64-apple-darwin14.tar.gz", "43ca1837baf37df895e5791d4da6c52030b47359b36c3b08bded041774b33ef8"),
    "win32" => ("$bin_prefix/nettle.i686-w64-mingw32.tar.gz", "5893dd0be244c31e653c8076dc414d7f06fa27aece910d12f1e976fb19fcfb98"),
    "win64" => ("$bin_prefix/nettle.x86_64-w64-mingw32.tar.gz", "9b47d73bf03e40c978f4757a7a67fce92a9c073deb68cf6b91ce2154ae5625c3"),
)
if platform_key() in keys(downloads)
    url, hash = downloads[platform_triplet(platform_key())]
    @BP_provides(url, hash, nettle)
end



# Hopefully, we never have to use any of these things down here
if is_windows()
    using WinRPM
    provides(WinRPM.RPM, "libnettle-6-2", nettle, os = :Windows )
end

if is_apple()
    using Homebrew
    provides( Homebrew.HB, "nettle", nettle, os = :Darwin )
end

provides( AptGet, "libnettle4", nettle )
provides( Yum, "nettle", nettle )

julia_usrdir = normpath(JULIA_HOME*"/../") # This is a stopgap, we need a better built-in solution to get the included libraries
libdirs = AbstractString["$(julia_usrdir)/lib"]
includedirs = AbstractString["$(julia_usrdir)/include"]
env = @compat Dict("HOGWEED_LIBS" => "-L$(libdirs[1]) -L$(BinDeps.libdir(nettle)) -lhogweed -lgmp",
       "NETTLE_LIBS" => "-L$(libdirs[1]) -L$(BinDeps.libdir(nettle)) -lnettle -lgmp",
       "LD_LIBRARY_PATH" => join([libdirs[1];BinDeps.libdir(nettle);get(ENV,"LD_LIBRARY_PATH","")],":"))

provides( Sources,
          URI("http://www.lysator.liu.se/~nisse/archive/nettle-2.7.1.tar.gz"),
          SHA="bc71ebd43435537d767799e414fce88e521b7278d48c860651216e1fc6555b40",
          nettle )
provides( BuildProcess,
          Autotools(lib_dirs = libdirs,
                    include_dirs = includedirs,
                    env = env,
                    configure_options = ["--disable-openssl", "--libdir=$(BinDeps.libdir(nettle))"]),
          nettle )

@compat @BinDeps.install Dict(:nettle => :nettle)

using BinDeps
using Compat
using BinaryProvider
# Include BinaryProvider's BinDeps integration
include(Pkg.dir("BinaryProvider", "src", "BinDepsIntegration.jl"))

@BinDeps.setup

nettle = library_dependency("nettle", aliases = ["libnettle","libnettle-4-6","libnettle-6-1","libnettle-6-2"])

# BinaryProvider support
const prefix="https://github.com/staticfloat/NettleBuilder/releases/download/v3.3.2"
const downloads = Dict(
    "aarch64-linux-gnu" => ("$prefix/nettle.aarch64-linux-gnu.tar.gz", "34f3c9453a4c523b555f00f8fc17534f504f7d5e6e74360b77e88c88e2d76b1e"),
    "powerpc64le-linux-gnu" => ("$prefix/nettle.powerpc64le-linux-gnu.tar.gz", "6bdbd9273d16e9c8a81755d0f164bb67dfc7ac97061f6ef83a4253dc56e8a363"),
    "x86_64-linux-gnu" => ("$prefix/nettle.x86_64-linux-gnu.tar.gz", "cd031f560456f6ff66bc0b4d38235826116671f13c1ba78d90d7cc8fd91700e9"),
    "x86_64-apple-darwin14" => ("$prefix/nettle.x86_64-apple-darwin14.tar.gz", "7bd084b2a619ca6b87c8cf3dee201c289ee5b0ee41da95d8417bdcdae6a27524"),
    "x86_64-w64-mingw32" => ("$prefix/nettle.x86_64-w64-mingw32.tar.gz", "b2810b88da10dd02a47f5ec0b4b84bd943e046447b9b07899858aee4b6ce540f"),
    "arm-linux-gnueabihf" => ("$prefix/nettle.arm-linux-gnueabihf.tar.gz", "1af16aa5d7701c4bccb3041673c051ecb6ca7cb429853b33297f51278df5618a"),
)
if platform_triplet(platform_key()) in keys(downloads)
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

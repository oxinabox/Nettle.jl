using BinaryProvider

# BinaryProvider support
const prefix = Prefix(joinpath(dirname(dirname(@__FILE__)),"deps","usr"))
 
# We only care about libnettle, get it put into our `deps.jl` file:
libnettle = LibraryProduct(prefix, "libnettle")
# We're also going to find `nettle-hash` and `nettle.pc` for completeness
nettlehash = ExecutableProduct(prefix, "nettle-hash")
nettlepc = FileProduct(joinpath(libdir(prefix), "pkgconfig", "nettle.pc"))

# This is where we download things from, for different platforms
const bin_prefix="https://github.com/staticfloat/NettleBuilder/releases/download/v3.3.5"
const download_info = Dict(
    :linuxaarch64 => ("$bin_prefix/nettle.aarch64-linux-gnu.tar.gz", "c70f000013b6eb92fb268d7050089df0962ffa18524e26b9fec72179c7bbe5cc"),
    :linuxppc64le => ("$bin_prefix/nettle.powerpc64le-linux-gnu.tar.gz", "413572f1661ff362af2e0c1e918c0a463f0158543ec66afcb91347a7be900aea"),
    :win32 => ("$bin_prefix/nettle.i686-w64-mingw32.tar.gz", "711466e651ec2a79af1351c27045d8df6e15b1e2a14a3d02eeeceda399e0267a"),
    :linux64 => ("$bin_prefix/nettle.x86_64-linux-gnu.tar.gz", "faed8b429aead624cc7549e48675a4b8f235e96099e29a75e9f979ab129ff06e"),
    :mac64 => ("$bin_prefix/nettle.x86_64-apple-darwin14.tar.gz", "986a1ab2aecf5bf5105a594fbc63c1f1637c581d84f83c419e88421e68c9c1bb"),
    :win64 => ("$bin_prefix/nettle.x86_64-w64-mingw32.tar.gz", "266b1fef5af35c5b41ba68b3c6fe9bb265a61e9f7c11a1d4a5d11a7af6d44da9"),
    :linuxarmv7l => ("$bin_prefix/nettle.arm-linux-gnueabihf.tar.gz", "98ecfcbeb966303c2e48aaeaa045a6d96f6b65b702bf7d76e88fd311b8354a0a"),
    :linux32 => ("$bin_prefix/nettle.i686-linux-gnu.tar.gz", "3f4b0a8ebe0bd85273ebd4527cbf4ee43561eaae5d60d66603f71e7655f2f8b3"),
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



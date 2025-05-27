Essentially it's a tool, tinderbox, that automates the process of checking out and building a recent FFmpeg source code, including nonfree libraries such as libfdk-aac and decklink.

For a manual build, follow detailed instructions below:

---

##  Prelude

***Requirements***

Ensure you have the following tools installed on your system:

- **Bash**
- **Docker**

***Targets, Variants and Addins***

#### Targets:

- `win64`: Build for 64-bit Windows
- `win32`: Build for 32-bit Windows

#### Variants:

- `gpl`: Builds all libraries from `scripts.d` folder *except* `libfdk-aac` and `decklink`
- `lgpl`: Excludes additional libraries (`avisynth`, `davs2`, `vidstab`, `x264`, `x265` and `xavs2`)
- `nonfree`: Includes both non-free libraries (`libfdk-aac` and `decklink`) and all libraries of the gpl variant

#### Addins:

- `debug`: Adds debug symbols to the build. It's `gdb` compatible embedded debug info

##  Building

1. Build base-image:

```console
docker build -t ghcr.io/nanake/base-${TARGET}:latest images/base-${TARGET}
```

*Note:* You might need to modify the *rootfs* image by specifying a public image base, such as `fedora:rawhide`.

2. Build target-variant image:

```console
./generate.sh ${TARGET} ${VARIANT}
docker build -t ghcr.io/nanake/${TARGET}-${VARIANT}:latest .
```
*Alternatively*, You can build both *base-image* and *target-variant* image by simply invoke `makeimage.sh`. For example:

```console
./makeimage.sh win64 nonfree
```

3. Build FFmpeg

```console
./build.sh ${TARGET} ${VARIANT} ${ADDINS}
```
To create a `shared` build of FFmpeg, append `-shared` to the `VARIANT` name. For example:

```console
./build.sh win64 gpl-shared
```
Upon successful build completion, the build artifacts will be available in the `artifacts` folder.

---

## Enabled libraries

- iconv
- libxml2
- zlib
- libfreetype
- libfribidi
- gmp
- lzma
- libharfbuzz
- libfontconfig
- libvorbis
- opencl
- libvmaf
- amf
- avisynth
- chromaprint
- cuda-llvm
- decklink
- ffnvcodec
- libaribcaption
- libass
- libbluray
- libdav1d
- libdavs2
- libdvdnav
- libdvdread
- libfdk-aac
- libgme
- libjxl
- libkvazaar
- liblc3
- liblcevc-dec
- libmp3lame
- liboapv
- libopencore-amrnb
- libopencore-amrwb
- libopenh264
- libopenjpeg
- libopenmpt
- libopus
- libplacebo
- librav1e
- librist
- librubberband
- libshaderc
- libsnappy
- libsoxr
- libsrt
- libssh
- libsvtav1
- libtheora
- libtwolame
- libuavs3d
- libvidstab
- libvpl
- libvpx
- libvvenc
- libwebp
- libx264
- libx265
- libxavs2
- libxevd
- libxeve
- libzimg
- libzmq
- libzvbi
- openal
- schannel
- sdl2
- vaapi
- vulkan

---

###  Acknowledgments

The foundation for this build script comes from the work of [BtbN](https://github.com/BtbN/FFmpeg-Builds).


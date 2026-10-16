# FFmpeg Build Environment

This repository provides a Docker-based build environment for compiling recent git versions of FFmpeg, including optional GPL and non-free libraries such as `libfdk-aac`, `libfdk-xhe-aac`, `libmpeghdec`, `LCEVCdec`, and `DeckLink`.

The project automates dependency compilation and FFmpeg builds for supported targets.

## Requirements

Make sure the following tools are installed:

- Bash
- Docker

## Build Configuration

### Targets

| Target | Description |
|----------|-------------|
| `win64` | 64-bit Windows |

### Variants

| Variant | Description |
|----------|-------------|
| `lgpl` | Builds FFmpeg with LGPL-compatible libraries only |
| `gpl` | Includes all LGPL libraries plus GPL components |
| `nonfree` | Includes GPL libraries and non-free components such as libfdk-aac, libfdk-xhe-aac, LCEVCdec,  libmpeghdec, and DeckLink |

### Add-ins

| Add-in | Description |
|---------|-------------|
| `debug` | Embeds GDB-compatible debug symbols |

## Building Docker Images

### Build the Base Image

```bash
docker build \
    -t base-win64:latest \
    images/base-win64
```

### Generate the Target Dockerfile

```bash
./generate.sh <target> <variant> <add-in>
```

### Build the Target Image

```bash
docker build \
    -t <target>-<variant>-<add-in>:latest .
```

### Build Everything Automatically
Instead of running the previous steps manually:

```bash
./makeimage.sh <target> <variant> <add-in>
```

This command generates and builds both the base image and the target image.

## Building FFmpeg

Build FFmpeg using a target and variant:

```bash
./build.sh <target> <variant> <add-in>
```

### Shared Build
To build FFMpeg shared libraries instead of static ones, append -shared to the variant:

```bash
./build.sh <target> <variant>-shared <add-in>
```

### Output
After a successful build, the generated binaries and packages can be found in `artifact` folder

## Enabled Libraries

The build environment currently supports the following libraries and features:


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
- lcms2
- libaribcaption
- libass
- libbluray
- libcurl
- libdav1d
- libdavs2
- libdvdnav
- libdvdread
- libfdk-aac
- libfdk-xhe-aac
- libgme
- libjxl
- libkvazaar
- liblc3
- liblcevc-dec
- libmp3lame
- libmpeghdec
- libmysofa
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
- libsvtjpegxs
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
- vapoursynth
- vulkan
- whisper

##  Acknowledgments

This project is heavily inspired by the excellent work in [BtbN](https://github.com/BtbN/FFmpeg-Builds).

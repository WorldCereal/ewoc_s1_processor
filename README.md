# S1Tiling Docker

## Build S1Tiling docker image

To build the docker you need to put with the Dockerfile:

- the linux binaries of [CMake 3.18.4](https://cmake.org/files/v3.18/cmake-3.18.4-Linux-x86_64.tar.gz)
- the linux binaries of [OTB-7.3.0](https://www.orfeo-toolbox.org/packages/OTB-7.3.0-Linux64.run)

You can now run the following command to buid the docker image:

:warning: change the tag_name as you want

```sh
docker build -t s1tiling:tag_name "."
```

## Use S1Tiling docker image

## Prerequisites

You need to mount a volume which will be used by S1Tiling. This volume must:

- contain the input S1 GRD data
- contain the srtm data
- will be used to output data

If you are not interested by the temporary data, you can use the `/tmp` of the image.

:grey_exclamation: the config file of S1Tiling must be done according to the path of volume used by the image and not your local path.

:warning: EODAG usage is not currently supported

## Usage

With the following command you will obtain the help of S1Tiling:

:warning: adapt the `tag_name` to the previous one

```sh
docker run --rm  s1tiling:tag_name
```

If you want run S1Tiling, you can adapt the following command:

```sh
docker run --rm -v /local/path/to/data:/data s1tiling:tag_name /path/to/conf.file
```

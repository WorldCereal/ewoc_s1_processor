# EWoC Sentinel 1 processor docker image

## Build EWoC Sentinel 1 processor docker image

To build the docker you need to have the following private python packages close to the Dockerfile:

- eotile
- dataship
- ewoc_s1

You can now run the following command to build the docker image:

```sh
docker build --build-arg EWOC_S1_DOCKER_VERSION=$(git describe) --pull --rm -f "Dockerfile" -t ewocs1processing:$(git describe) "."
```

### Advanced usage

:warning: this usage is not guarantee

You can pass the following version with `--build-arg` option to bypass encoded version:

- `OTB_VERSION`
- `EWOC_S1_VERSION`
- `EWOC_DATASHIP_VERSION`
- `EOTILE_VERSION`

## Use EWoC Sentinel 1 processor docker image

### Local usage (outside Argo workflow)

You need to pass to the docker image a file with some credentials with the option `--env-file /path/to/env.file`.

- To run the generation of ARD from S1 product ID with upload of data:

:warning: Adapt the `tag_name` to the right one

```sh
docker run --rm --env-file /local/path/to/env.file ewocs1processing:tag_name ewoc_s1_generate_ard_pid S1_PRD_ID_1 S1_PRD_ID_2 ... --upload -v
```

If you are interested by the temporary data or if you want retrieve output data whitout upload you need to mount volume with the option `-v / --volume` and use the docker path in the command line.

- To run the generation of ARD from work plan with upload of data:

:warning: Adapt the `tag_name` to the right one

```sh
docker run --rm -v /local/path/to/data:/data --env-file /local/path/to/env.file ewocs1processing:tag_name ewoc_s1_generate_ard_wp /data/path/to/wp.json --upload -v
```

:grey_exclamation: Please consult the help of `ewoc_s1` for more information on the ewoc_s1 CLI.

### Argo Workflow usage

:grey_exclamation: Environnement variables are provided by Argo Workflow

:warning: adapt the `tag_name` to the previous one

:exclamation: Not currently implemented

```sh
docker run --rm ewocs1processing:tag_name ewoc_s1_generate_ard_db -v
```

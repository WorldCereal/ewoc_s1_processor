# EWoC Sentinel 1 processor docker image

## Build EWoC Sentinel 1 processor docker image

To build the docker you need to have the following private python packages close to the Dockerfile:

- ewoc_dag
- ewoc_s1

You can now run the following command to build the docker image:

```sh
docker build --build-arg EWOC_S1_DOCKER_VERSION=$(git describe) --pull --rm -f "Dockerfile" -t ewocs1processing:$(git describe) "."
```

### Advanced build

:warning: No guarantee on the results

You can pass the following version with `--build-arg` option to bypass encoded version:

- `OTB_VERSION`
- `EWOC_S1_VERSION`
- `EWOC_DATASHIP_VERSION`
- `EOTILE_VERSION`

## Use EWoC Sentinel 1 processor docker image

### Retrieve EWoC Sentinel-1 processor docker image

```sh
docker login 643vlk6z.gra7.container-registry.ovh.net -u ${harbor_username}
docker pull 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewocs1processing:${tag_name}
```

#### Generate S1 ARD from S1 product ID

To run the generation of ARD from S1 product ID with upload of data, you need to pass to the docker image a file with some credentials with the option `--env-file /path/to/env.file`. This file contains the variables related to `ewoc_dag`

:warning: Adapt the `tag_name` to the right one

```sh
docker run --rm --env-file /local/path/to/env.file ewocs1processing:${tag_name} ewoc_generate_s1_ard -v prd_ids TILE_ID S1_PRODUCT_ID_1 S1_PRODUCT_ID_2 ...
```

If you are interested by the temporary data or if you want retrieve output data whitout upload you need to mount volume with the option `-v / --volume` and use the docker path in the command line.

:grey_exclamation: Please consult `ewoc_s1`  for more information on the ewoc_s1 CLI.

## Push EWoC Sentinel-1 processor docker image

:warning: Push is done by github-actions! Use these commands only in specific case.

```sh
docker login 643vlk6z.gra7.container-registry.ovh.net -u ${harbor_username}
docker tag ewocs1processing:${tag_name} 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewocs1processing:${tag_name}
docker push 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewocs1processing:${tag_name}
```

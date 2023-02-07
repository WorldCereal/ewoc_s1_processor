# EWoC Sentinel 1 processor docker image

## Use EWoC Sentinel 1 processor docker image

### Retrieve EWoC Sentinel-1 processor docker image

```sh
docker login 643vlk6z.gra7.container-registry.ovh.net -u ${harbor_username}
docker pull 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewocs1processing:${tag_name}
```

#### Generate S1 ARD from S1 product ID

To run the generation of ARD from S1 product ID with upload of data, you need to pass to the docker image a file with some credentials with the option `--env-file /path/to/env.file`. This file contains the variables related to `ewoc_dag` and the following one `EWOC_S1_DEM_DB=/opt/dem_tiles_cop.gpkg`. For a test on aws, you need to set: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` with our credentials and `EWOC_CLOUD_PROVIDER=aws`.

:warning: Adapt the `tag_name` to the right one

Example:

```sh
docker run --rm --env-file /local/path/to/env.file 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewocs1processing:${tag_name} ewoc_generate_s1_ard -v --data-source aws --dem-source ewoc prd_ids 36TWR S1A_IW_GRDH_1SDV_20181102T153633_20181102T153700_024411_02ACA1_105A S1A_IW_GRDH_1SDV_20181102T153608_20181102T153633_024411_02ACA1_2B2C
```

If you are interested by the temporary data or if you want retrieve output data whitout upload you need to mount volume with the option `-v / --volume` and use the docker path in the command line.

:grey_exclamation: Please consult `ewoc_s1`  for more information on the ewoc_s1 CLI.

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
- `EWOC_DAG_VERSION`

## Push EWoC Sentinel-1 processor docker image

### To OVH Harbor

:warning: Push is done by github-actions! Use these commands only in specific case.

```sh
docker login 643vlk6z.gra7.container-registry.ovh.net -u ${harbor_username}
docker tag ewocs1processing:${tag_name} 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewocs1processing:${tag_name}
docker push 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewocs1processing:${tag_name}
```

### Move from OVH Harbor to AWS ECR

```sh
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 501872996718.dkr.ecr.eu-central-1.amazonaws.com
docker pull 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewoc_classif:${tag_name}
docker tag 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewocs1processing:${tag_name} 501872996718.dkr.ecr.eu-central-1.amazonaws.com/world-cereal/ewocs1processing:${tag_name}
docker push  501872996718.dkr.ecr.eu-central-1.amazonaws.com/world-cereal/ewocs1processing:${tag_name}
```

#/bin/bash
export USER_NAME=fl64
for i  in ui post-py comment; do cd ../src/$i; bash docker_build.sh; cd -; done
docker build -t $USER_NAME/prometheus ../monitoring/prometheus/

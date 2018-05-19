USER_NAME = fl64
# Run `make VMNAME=machinename` to override the default
VMNAME = vm1
#dont forget set var. For example GOOGLE_PROJECT = docker-201818
GOOGLE_PROJECT = docker-201818

.PHONY: all init destroy build build_ui build_comment build_post build_prometheus build_mongodb_exporter push_ui push_comment push_post push_prometheus push_mongodb_exporter app_start app_stop app_restart rebuild

### init and destroy
all: init app_start

init:
	export GOOGLE_PROJECT=$(GOOGLE_PROJECT); \
	docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    $(VMNAME)

# env:
#	export DOCKER_MACHINE_NAME=$(shell docker-machine env $(VMNAME) | grep 'DOCKER_MACHINE_NAME=".*"' | cut -d\" -f2); \
#	export DOCKER_TLS_VERIFY=$(shell docker-machine env $(VMNAME) | grep 'DOCKER_TLS_VERIFY=".*"' | cut -d\" -f2); \
#	export DOCKER_HOST=$(shell docker-machine env $(VMNAME) | grep 'DOCKER_HOST=".*"' | cut -d\" -f2); \#
#	export DOCKER_CERT_PATH=$(shell docker-machine env $(VMNAME) | grep 'DOCKER_CERT_PATH=".*"' | cut -d\" -f2)


destroy:
	docker-machine rm $(VMNAME) -f # && eval $(docker-machine env -u)


### Build section
build: build_ui build_comment build_post build_prometheus build_mongodb_exporter
build_ui:
	cd src/ui && bash docker_build.sh
build_comment:
	cd src/comment && bash docker_build.sh
build_post:
	cd src/post-py && bash docker_build.sh
build_prometheus:
	docker build -t $(USER_NAME)/prometheus monitoring/prometheus
build_mongodb_exporter:
	docker build -t $(USER_NAME)/mongodb_exporter monitoring/mongodb_exporter

### Push images
push: push_ui push_comment push_post push_prometheus push_mongodb_exporter
push_ui:
	docker push $(USER_NAME)/ui
push_comment:
	docker push $(USER_NAME)/comment
push_post:
	docker push $(USER_NAME)/post
push_prometheus:
	docker push $(USER_NAME)/prometheus
push_mongodb_exporter:
	docker push $(USER_NAME)/mongodb_exporter

### App
app_start:
	cd docker && docker-compose up -d
app_stop:
	cd docker && docker-compose down
app_restart: app_stop app_start

### Rebuild and restart all
rebuild: build push app_restart

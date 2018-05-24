USER_NAME = fl64
# Run `make VM_NAME=machinename` to override the default
VM_NAME = vm1
#dont forget set var. For example GOOGLE_PROJECT = docker-201818
GOOGLE_PROJECT = docker-201818

.PHONY: init destroy build build_ui build_comment build_post build_prometheus build_mongodb_exporter push_ui push_comment push_post push_prometheus push_mongodb_exporter app_start app_stop app_restart rebuild

### init and destroy
init:
	export GOOGLE_PROJECT=$(GOOGLE_PROJECT) \
	&& gcloud compute firewall-rules create prometheus-default --allow tcp:9090 | true \
	&& gcloud compute firewall-rules create puma-default --allow tcp:9292 | true \
	&& docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    $(VM_NAME)

destroy:
	gcloud compute firewall-rules delete puma-default --quiet | true \
	&& gcloud compute firewall-rules delete prometheus-default --quiet | true \
	&& docker-machine rm $(VM_NAME) -f


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

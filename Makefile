USER_NAME = fl64
# Run `make VM_NAME=machinename` to override the default
VM_NAME = vm1
#dont forget set var. For example GOOGLE_PROJECT = docker-201818
GOOGLE_PROJECT = docker-201818

.PHONY: init init_vm init_fw
		destroy destroy_fw destroy_vm ip
		build build_ui build_comment build_post build_prometheus build_mongodb_exporter build_alert_manager
		push push_ui push_comment push_post push_prometheus push_mongodb_exporter push_alert_manager
		app_start app_stop app_restart
		mon_start mon_stop mon_restart
		start stop restart rebuild

### Docker machine section
init: init_fw init_vm
init_vm:
	export GOOGLE_PROJECT=$(GOOGLE_PROJECT) \
	&& docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --engine-opt experimental --engine-opt metrics-addr=0.0.0.0:9323 \
    $(VM_NAME)
init_fw:
	export GOOGLE_PROJECT=$(GOOGLE_PROJECT) \
	&& gcloud compute firewall-rules create prometheus-default --allow tcp:9090 | true \
	&& gcloud compute firewall-rules create puma-default --allow tcp:9292 | true \
	&& gcloud compute firewall-rules create cadviser-default --allow tcp:8080 | true \
	&& gcloud compute firewall-rules create grafana-default --allow tcp:3000 | true \
	&& gcloud compute firewall-rules create alert-manager-default --allow tcp:9093 | true \
	&& gcloud compute firewall-rules create docker-mon-default --allow tcp:9323 | true \
destroy: destroy_fw destroy_vm
destroy_fw:
	export GOOGLE_PROJECT=$(GOOGLE_PROJECT) \
	&& gcloud compute firewall-rules delete puma-default --quiet | true \
	&& gcloud compute firewall-rules delete prometheus-default --quiet | true \
	&& gcloud compute firewall-rules delete cadviser-default --quiet | true \
	&& gcloud compute firewall-rules delete grafana-default --quiet | true \
	&& gcloud compute firewall-rules delete alert-manager-default --quiet | true \
	&& gcloud compute firewall-rules delete docker-mon-default --quiet | true \
destroy_vm:
	export GOOGLE_PROJECT=$(GOOGLE_PROJECT) \
	&& docker-machine rm $(VM_NAME) -f
ip:
	docker-machine ip $(VM_NAME)

### Build section
build: build_ui build_comment build_post build_prometheus build_mongodb_exporter build_alert_manager
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
build_alert_manager:
	docker build -t $(USER_NAME)/alertmanager monitoring/alertmanager/

### Push images section
push: push_ui push_comment push_post push_prometheus push_mongodb_exporter push_alert_manager
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
push_alert_manager:
	docker push $(USER_NAME)/alertmanager

### App section
app_start:
	cd docker && docker-compose up -d | true
app_stop:
	cd docker && docker-compose down | true
app_restart: app_stop app_start

### Monitoring section
mon_start:
	cd docker && docker-compose -f docker-compose-monitoring.yml up -d | true
mon_stop:
	cd docker && docker-compose -f docker-compose-monitoring.yml down | true
mon_restart: mon_stop mon_start

### App and mon section
start:
	cd docker && docker-compose -f docker-compose.yml -f docker-compose-monitoring.yml up -d
stop:
	cd docker && docker-compose -f docker-compose.yml -f docker-compose-monitoring.yml down
restart: stop start
rebuild: build push stop start

teststop:
	cd docker && docker-compose stop post
teststart:
	cd docker && docker-compose start post

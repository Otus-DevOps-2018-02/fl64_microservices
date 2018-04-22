# fl64_microservices
fl64 microservices repository

# Table of content

- [Table of content](#table-of-content)
- [13. Homework-13: Docker-1](#13-homework-13-docker-1)
    - [13.1 What was done](#131-what-was-done)
    - [13.2 How to run the project](#132-how-to-run-the-project)
    - [13.3 How to check](#133-how-to-check)
- [14. Homework-14: Docker-2](#14-homework-14-docker-2)
    - [14.1 What was done](#141-what-was-done)
    - [14.2 How to run the project](#142-how-to-run-the-project)
    - [14.3 How to check](#143-how-to-check)

# 13. Homework-13: docker-1

## 13.1 What was done
- установлен и настроен docker (https://docs.docker.com/install/linux/docker-ce/fedora/)
- ДЗ выполнено в полном объеме
В рамках задания со *:
- в файл docker-monolith/docker-1.log добавлена информация по заданию со *

## 13.2 How to run the project

None

## 13.3 How to check

Ознакомиться с содержимым: docker-monolith/docker-1.log

# 14. Homework-14: docker-2

## 14.1 What was done

- создан новый проект в GCP (docker-XXXXXX)
- в новом проекте GCP создан хост с использованием docker-machine
- создан контенер reddit
- проверена его работоспособность
- контейнер загружен на DockerHub

В рамках задания со *:
- создана конфигурация terraform для развертывания образа системы для установки docker, число экземлляров задается в переменно `dockerhost_count` (значение по умолчанию = 2);
- созданы ansible-плейбуки для установки docker, для запуска приложения reddit
- создана конфигурация packer, позволяющая создать обоаз ОС (ubuntu 16.04lts) с предустановленным docker.

## 14.2 How to run the project
### 14.2.1 Base
- создать проект в GCP, влключить доступ к API
- настроить подключение к GCP, если оно не было ранее создано:
```
install GCloud SDK (https://cloud.google.com/sdk/)
gcloud init
gcloud auth application-default login
```
- установить docker-machine (https://docs.docker.com/machine/install-machine/)
- в GCP создать инстанс с использованием dockermachine: docker-host
```
docker-machine create --driver google --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts --google-machine-type n1-standard-1 --google-zone europe-west4-a docker-host

Enable API (https://console.developers.google.com/apis/api/compute.googleapis.com/overview?project=docker-XXXXXX&authuser=3)

docker-machine env docker-host

docker-machine ls
eval $(docker-machine env docker-host)
docker-machine ssh docker-host
```
- создать контейнер reddit и запустить его
```
docker build -t reddit:latest .
docker run --name reddit -d --network=host reddit:latest
```
- не забыть добавить правила на МЭ
```
gcloud compute firewall-rules create reddit-app --allow tcp:9292 --target-tags=docker-machine --description="Allow PUMA connections" --direction=INGRESS

```
- загрузить созданный контейнер на DockerHub
```
docker login
docker tag reddit:latest fl64/otus-reddit:1.0
docker push fl64/otus-reddit:1.0
```

- запуск контейнера
```
docker run --name reddit -d -p 9292:9292 fl64/otus-reddit:1.0
```

### 14.2.1 *

Предполагается, что все действия происходят в каталоге `docker-monolith`:
- создать к ssh-ключи для подключения к инстансам
```
ssh-keygen -t rsa -f dockerhost -C 'dockerhost' -q -N ''
mv dockerhost* ~/.ssh/
chmod 0600 ~/.ssh/dockerhost*
```
- `cd infra/terraform`
	- `terraform init`
	- `terraform validate -var-file=terraform.tfvars`
	- `terraform plan -var-file=terraform.tfvars`
	- `terraform apply -var-file=terraform.tfvars`
- `cd ../ansible`
	- `ansible-playbook dockerhost.yaml`
	- `ansible-playbook dockerapp.yaml`
- `cd ../packer`
	- `packer validate -varfile=variables.json`
	- `packer build -varfile=variables.json`

## 14.3 How to check

- `cd terraform`, запустить `terraform output`, в браузере перейти по адресам, отображенным в выводе.
- перейти в GCP (https://console.cloud.google.com), Compute engine -> images, в списке будет присуствовать созданный packer'ом образ **docker-host-xxxxxxxxxx**
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
- [15. Homework-15: Docker-3](#15-homework-15-docker-3)
    - [15.1 What was done](#151-what-was-done)
    - [15.2 How to run the project](#152-how-to-run-the-project)
    - [15.3 How to check](#153-how-to-check)
- [16. Homework-16: Docker-4](#16-homework-16-docker-4)
    - [16.1 What was done](#161-what-was-done)
    - [16.2 How to run the project](#162-how-to-run-the-project)
    - [16.3 How to check](#163-how-to-check)

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
export GOOGLE_PROJECT=docker-XXXXXX

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

### 14.2.2 *

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


# 15. Homework-15: docker-3

## 15.1 What was done

- созданы образы docker для приложения RedditApp
- конфигурации Docekrfile приведены в порядок в соотвествии с Best practices (Hadolint)
- приложение разворачивается на docker-machine в облаке GCP, при этом данные приложения, при остановке контейнеров сохраняются

В рамках задания со *\**:
- образа контейнеров запущены с другими сетевыми алиасами
- объем образа UI оптимизирован путем использования образа alpine и удаления ненужных данных из образа:
	- в первом случае размер робраза был сокращен с 394 Мб до 208 Мб
	- во втором с 208 Мб до 55.6 Мб

## 15.2 How to run the project
### 15.2.1 Base
- установить Google Cloud SDK, настроить подключение
- запустить создание docker-machine
```
export GOOGLE_PROJECT=docker-XXXXXX

docker-machine create --driver google --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts --google-machine-type n1-standard-1 --google-zone europe-west4-a docker-host

eval $(docker-machine env docker-host)

docker-machine ls
```
- добавить праивла для МЭ
```
gcloud compute firewall-rules create reddit-app --allow tcp:9292 --target-tags=docker-machine --description="Allow PUMA connections" --direction=INGRESS

```
- `cd src\`
- прогнать контейнеры в линетере, убедится в отсуствии критичных замечаний
```
docker run --rm -i hadolint/hadolint < ui\Dockerfile
docker run --rm -i hadolint/hadolint < post-py\Dockerfile
docker run --rm -i hadolint/hadolint < comment\Dockerfile

```
- запустить билд контейнеров
```
docker build -t fl64/post:1.0 ./post-py
docker build -t fl64/comment:1.0 ./comment
docker build -t fl64/ui:1.0 ./ui
```

- создать сетевое окружение
```
docker network create reddit

```
- создать область для хранения данных БД
```
docker volume create reddit_db
```

- создать контейнеры и запустить их
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest \
&& docker run -d --network=reddit --network-alias=post fl64/post:1.0
&& docker run -d --network=reddit --network-alias=comment fl64/comment:1.0
&& docker run -d --network=reddit -p 9292:9292 fl64/ui:1.0
```

### 15.2.2 *

Запуск контейнеров с другими сетевыми алиасами
- убить все контейнеры! слава роботам!
![](https://static1.squarespace.com/static/588bb37b893fc0698d8db5f6/t/58d96d5f03596eed05f898f9/1490644323456/?format=300w)
```
docker kill $(docker ps -q)

```
- запустить все с новыми алиасами
```
docker run -d --network=reddit --network-alias=another_post_db --network-alias=another_comment_db mongo:latest \
&& docker run --env POST_DATABASE_HOST=another_post_db -d --network=reddit --network-alias=another_post fl64/post:1.0 \
&& docker run --env COMMENT_DATABASE_HOST=another_comment_db -d --network=reddit --network-alias=another_comment fl64/comment:1.0 \
&& docker run --env COMMENT_SERVICE_HOST=another_comment --env POST_SERVICE_HOST=another_post  -d --network=reddit -p 9292:9292 fl64/ui:1.0
```

### 15.2.3 *

Оптимизация размера
- убить все контейнеры
```
docker kill $(docker ps -q)

```
- запустить приложение с новой версией UI
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest \
&& docker run -d --network=reddit --network-alias=post fl64/post:1.0
&& docker run -d --network=reddit --network-alias=comment fl64/comment:1.0
&& docker run -d --network=reddit -p 9292:9292 fl64/ui:3.0
```

В части оптимизации были удалены пакеты для разработки, очищен кэш установленных пакетов.
Для оптимизации использовались следующиме материалы и гугл:
- http://blog.kontena.io/dockerizing-ruby-application/
- https://blog.codeship.com/build-minimal-docker-container-ruby-apps/

## 15.3 How to check

- выполниьт `docker-machine ip docker-host`
- перейти по адресу, указанному в выводе предыдущей команды + порт 9292

# 16. Homework-16: docker-4

## 16.1 What was done

- изучены варианты запуска контенера с различными сетевыми драйверами (none, host, bridge);
- произведена установка и создание файла конфигурации для docker-compose

в рамках задания со *:
- создан файл переопределений docker-compose.override.yml для запуска приложений контенеров в отладочном режиме, с возможностью редактирования кода приложений без необходимости пересоздания образа Docker.

## 16.2 How to run the project
### 16.2.1 Base
- установить Google Cloud SDK, настроить подключение
- запустить создание docker-machine
```
docker-machine create --driver google --google-project docker-XXXXXX --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts --google-machine-type n1-standard-1 --google-zone europe-west4-a docker-host

eval $(docker-machine env docker-host)
```
- добавить праивла для МЭ
```
gcloud compute firewall-rules create reddit-app --allow tcp:9292 --target-tags=docker-machine --description="Allow PUMA connections" --direction=INGRESS

```
- `cd src\`
- в файле `.env.example` указаны переменные окружения, необходимые для запуска docker-compose. Необходимо переименовать его в `.env` и пре необходимости изменить значения параметров.
- выполнить `docker-compose up -d`
- запустятся 4 контенера приложения
- для остановки и удаления контейнеров выполнить:
	- `docker-compose kill`
	- `docker-compose rm -f`
- создать сетевое окружение


### 16.2.2 *
Имя контенера, создаваемого docker-compose имеет следующий шаблон:
`<имя проекта>-<название образа>-<индекс>`
По умолчанию docker-compose в качестве имени проекта использует название каталога из котрого он запускается. Для переопределения данного параметра необходимо (на выбор):
1. Задать название проекта для переменной окружения COMPOSE_PROJECT_NAME
2. Запустить docker-comose с параметром `-p / --project-name`. 
Src link: https://docs.docker.com/compose/reference/envvars/#compose_project_name

### 16.2.3 *
- Пример файла переопределений docker-compose представлен в файле `docker-compose.override.yml.example`. Необходимо переименовать его в `docker-compose.override.yml`
- Предполагается, что тексты приложения находятся на хосте Docker-machine в каталоге `~/src`, для этого необходимо перенести тексты ПО путем выполения команды:
```
docker-machine ssh docker-host mkdir src; \
find . -regex ".*\(ui\|comment\|post-py\)" -type d -exec docker-machine scp -r {} docker-host:src  \;

```

## 16.3 How to check

- выполниьт `docker-machine ip docker-host`
- перейти по адресу, указанному в выводе предыдущей команды + порт 9292

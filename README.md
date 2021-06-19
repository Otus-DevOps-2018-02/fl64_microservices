[![Build Status](https://travis-ci.org/Otus-DevOps-2018-02/fl64_microservices.svg?branch=master)](https://travis-ci.org/Otus-DevOps-2018-02/fl64_microservices)

# fl64_microservices
fl64 microservices repository

# Table of content

- [Table of content](#table-of-content)
- [13. Homework-13: Docker-1](#13-homework-13-docker-1)
- [14. Homework-14: Docker-2](#14-homework-14-docker-2)
- [15. Homework-15: Docker-3](#15-homework-15-docker-3)
- [16. Homework-16: Docker-4](#16-homework-16-docker-4)
- [17. Homework-17: Gitlab-CI-1](#17-homework-17-gitlab-ci-1)
- [18. Homework-18: Gitlab-CI-1](#18-homework-18-gitlab-ci-2)
- [19. Homework-19: Monitoring-1](#19-homework-19-monitoring-1)
- [20. Homework-20: Monitoring-2](#20-homework-20-monitoring-2)
- [21. Homework-21: Logging-1](#21-homework-21-logging-1)
- [22. Homework-22: Kubernetes-1](#22-homework-22-kubernetes-1)
- [23. Homework-23: Kubernetes-2](#23-homework-23-kubernetes-2)
- [24. Homework-24: Kubernetes-3](#24-homework-24-kubernetes-3)
- [25. Homework-25: Kubernetes-4](#25-homework-25-kubernetes-4)
- [26. Homework-26: Kubernetes-5](#26-homework-26-kubernetes-5)

# 13. Homework-13: docker-1

## 13.1 Что было сделано
- установлен и настроен docker (https://docs.docker.com/install/linux/docker-ce/fedora/)
- ДЗ выполнено в полном объеме
В рамках задания со *:
- в файл docker-monolith/docker-1.log добавлена информация по заданию со *

## 13.2 Как запустить проект

None

## 13.3 Как проверить

Ознакомиться с содержимым: docker-monolith/docker-1.log

# 14. Homework-14: docker-2

## 14.1 Что было сделано

- создан новый проект в GCP (docker-XXXXXX)
- в новом проекте GCP создан хост с использованием docker-machine
- создан контенер reddit
- проверена его работоспособность
- контейнер загружен на DockerHub

В рамках задания со *:
- создана конфигурация terraform для развертывания образа системы для установки docker, число экземлляров задается в переменно `dockerhost_count` (значение по умолчанию = 2);
- созданы ansible-плейбуки для установки docker, для запуска приложения reddit
- создана конфигурация packer, позволяющая создать обоаз ОС (ubuntu 16.04lts) с предустановленным docker.

## 14.2 Как запустить проект
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
- не забыть добавить правила для МЭ
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
- создать к ssh-ключи для подключения к экземплярам VM
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
- `cd infra/ansible`
	- `ansible-playbook dockerhost.yaml`
	- `ansible-playbook dockerapp.yaml`
- `cd infra/packer`
	- `packer validate -varfile=variables.json`
	- `packer build -varfile=variables.json`

## 14.3 Как проверить

- `cd terraform`, запустить `terraform output`, в браузере перейти по адресам, отображенным в выводе.
- перейти в GCP (https://console.cloud.google.com), Compute engine -> images, в списке будет присуствовать созданный packer'ом образ **docker-host-xxxxxxxxxx**


# 15. Homework-15: docker-3

## 15.1 Что было сделано

- созданы образы docker для приложения RedditApp
- конфигурации Docekrfile приведены в порядок в соотвествии с Best practices (Hadolint)
- приложение разворачивается на docker-machine в облаке GCP, при этом данные приложения, при остановке контейнеров сохраняются

В рамках задания со *\**:
- образа контейнеров запущены с другими сетевыми алиасами
- объем образа UI оптимизирован путем использования образа alpine и удаления ненужных данных из образа:
	- в первом случае размер робраза был сокращен с 394 Мб до 208 Мб
	- во втором с 208 Мб до 55.6 Мб

## 15.2 Как запустить проект
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
- запустить все контейнеры с новыми алиасами
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

## 15.3 Как проверить

- выполниьт `docker-machine ip docker-host`
- перейти по адресу, указанному в выводе предыдущей команды + порт 9292

# 16. Homework-16: docker-4

## 16.1 Что было сделано

- изучены варианты запуска контенера с различными сетевыми драйверами (none, host, bridge);
- произведена установка и создание файла конфигурации для docker-compose

в рамках задания со *:
- создан файл переопределений docker-compose.override.yml для запуска приложений контенеров в отладочном режиме, с возможностью редактирования кода приложений без необходимости пересоздания образа Docker (для этого каталоги dockerhost монтируются в контейнеры).

## 16.2 Как запустить проект
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
- выполнить `docker-compose up -d`, запустятся 4 контенера приложения
- для остановки и удаления контейнеров выполнить:
	- `docker-compose kill`
	- `docker-compose rm -f`
- создать сетевое окружение

### 16.2.2 *
Имя контенера, создаваемого docker-compose имеет следующий шаблон:
`<имя проекта>-<название образа>-<индекс>`
По умолчанию docker-compose в качестве имени проекта использует название каталога из котрого он запускается. Для переопределения данного параметра необходимо (на выбор):
1. Задать название проекта для переменной окружения **COMPOSE_PROJECT_NAME**
2. Запустить docker-comose с параметром `-p / --project-name`.
Src link: https://docs.docker.com/compose/reference/envvars/#compose_project_name

### 16.2.3 *
- Пример файла переопределений docker-compose представлен в файле `docker-compose.override.yml.example`. Необходимо переименовать его в `docker-compose.override.yml`
- Предполагается, что тексты приложения находятся на хосте Docker-machine в каталоге `~/src`, для этого необходимо перенести тексты ПО путем выполения команды:
```
docker-machine ssh docker-host mkdir src; \
find . -regex ".*\(ui\|comment\|post-py\)" -type d -exec docker-machine scp -r {} docker-host:src  \;

```

## 16.3 Как проверить

- выполниьт `docker-machine ip docker-host`
- перейти по адресу, указанному в выводе предыдущей команды + порт 9292

# 17. Homework-17: Gitlab-CI-1

## 17.1 Что было сделано

- подготовлены скрипты Terraform + Ansible для разветывания GitLab CI;
- произведена настройка GitLib CI для выполнени тестов ДЗ;

в рамках задания со *:
- создан скрипт для автоматизации развертывания Gitlab CI runner.
- произвелдена инеграция Gitlab-CI с Slack с целью отправки сообщений.

## 17.2 Как запустить проект
### 17.2.1 Base
#### Создание инфраструктуры с Terraform
- `pushd .`
- `cd gitlab-ci/infra/terraform`
- `terraform init`
- `cp terraform.tfvars.example terraform.tfvars`
- `terraform plan -var-file=terraform.tfvars`
- `terraform apply -var-file=terraform.tfvars`
- `popd`

#### Установка docker + Gitlab CI с использванием Ansible
- `pushd .`
- `cd gitlab-ci/infra/ansible`
- Проверка доступности развернутого хоста `asnible -m ping host`
- `ansible-playbook playbooks/start.yaml`
- `popd`

P.S: Gitlab-CI создается при помощи Ansible, если нужно использовать только docker-compose, то:
- для роли gitlab-ci установить значене пееменной **create_docker_compose_file = true**
- перейти на созданную VM
- `docker-compose up -d`
- раннер создать "руками"
```
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```

#### Настройка Gitlab-CI
- перейти по ссылке  http://xx.xx.xx.xx, где xx.xx.xx.xx - внешний адрес созданной VM (можно получить путем выполнения `terraform output`)
- на стартовой странице Gitlab CI задать пароль пользователя root, и выполнить вход
- перейти по ссылке http://xx.xx.xx.xx/admin, Settings --> Sign-up restrictions, убрать маркер Sign-up enabled
- перейти по ссылке http://xx.xx.xx.xx/dashboard/groups --> New group --> Group name: homework
- перейти по ссылке http://xx.xx.xx.xx/projects/new --> Project-name: example
- перейти по ссылке http://xx.xx.xx.xx/homework/example/settings/ci_cd --> Runners settings, сохранить токен для настройки раннера
- перейти на созданную VM, далее выполнить настройку раннера `docker exec -it gitlab-runner gitlab-runner register`
- перейти по ссылке http://xx.xx.xx.xx/homework/example/settings/ci_cd --> Runners settings, отобразится созданный раннер
- выполнить `git remote add gitlab http://xx.xx.xx.xx/homework/example.git`
- выполнить `git push gitlab gitlab-ci-1`

### 17.2.2 * Интеграция Gitlab-CI + Slack
- Перейти в https://devops-team-otus.slack.com/apps/new/A0F7XDUAZ-incoming-webhooks
	- выбрать требуемый для интеграции канал Slack
	- скопировать значение Webhook
- Перейти в http://35.204.50.67/homework/example/settings/integrations
	- выбрать "Slack notifications"
	- установить маркер "active"
	- в поле "Webhook", добавить соответвующее значение полученное в Slack
	- установить имя пользователя "Username"

### 17.2.3 * Автоматизация развертывания раннеров

- Создана роль gitlab-ci-runners
- Перейти в gitlab-ci/infra/ansible
- Для роли необходим задать значения переменных:
	- Токен для установки раннеров задать в переменной **gitlabci_token**
	- Число раннеров задать в переменной **runners_count**
- запустить плейбук для установки нужного числа раннеров `ansible-playbook playbooks/runners.yaml`


## 17.3 Как проверить

- перейти по ссылке http://xx.xx.xx.xx/homework/example/pipelines, статус выполнения отображен как "passed"

Задание со *:
- Перейти по ссылке http://xx.xx.xx.xx/homework/example/settings/ci_cd, раскрыть "Runners settings". В списке будут отображаться установленные раннеры.
![](https://i.imgur.com/YWeKlYA.png)
- сообщения Gitlab CI отображаются в slack-канале: https://devops-team-otus.slack.com/messages/C9KNXLWAY/

# 18. Homework-18. Gitlab-CI-2

## 18.1 Что было сделано

- pipeline расширен окружениями dev,stage,prod;
- настроено динамическое окружение review для тестирования всех веток репозитория кроме master;

в рамках задания со *, **:
- в задаче build собирается образ приложения reddit и пушится на docker hub
- при пуше изменений во все ветки кроме master создается тестовый сервер (docker-machine), на которую деплоится собранный образ приложения
- удаление созданного сервера осуществляется путем запуска задачи "kill branch review"
## 18.2 Как запустить проект
### 18.2.1 Base

В Gitlab-CI
- создать проект example2
- подключить созданные ранее раннеры к проекту
- настроить git для пуша в git-репозиторий gitlab-ci: `git add remote http://gitlab-ci-ip/homework/example2.git`

### 18.2.3 *
- Для GCP настроить сервисную учетную запись с павами доступа к проекту, выгрузить json-файл учетными данными сервисной учетной записи (key.json).
- Заархивировать `tar -czvf secrets.tar.gz key.json`
- Зашифровать с использованием сложного пароля `openssl enc -aes-256-cbc -salt -in secrets.tar.gz -out secrets.tar.gz.enc -k very_strong_password -md sha1`
- Добавить в корень репозитория

В Gitlab CI настроить значения "секретных переменных" (http://gitlab-ci-ip/homework/example2/settings/ci_cd)
- DOCKER_USER - имя пользователя docker hub
- DOCKER_PASS - пароль пользоателя docker hub
- GCP_PASS - пароль для расшифровки данных сервисной учетной записи GCP - very_strong_password
- GCP_PROJECT - название проекта GCP

Краткое описание:
- изменения вносятся в репозиторий и пушатся на GitLab-CI
	- раннер необходимо регистрировать с параметром **--docker-privileged=true**
	- использовать сервис  **services: docker:dind** необходимый для сборки контейнера
- запускается задача Build, для которой собирается docker-образ приложения и пушится на docker hub с тегом [Название ветки git]-[id pipeline]
- в рамках задачи "branch review":
	- создается docker-machine в GCP
	- на ней поднимается приложение из docker hub созданное на этапе Build

![](https://i.imgur.com/Lk6vuk3.png)

## 18.3 Как проверить
- внести какие-либо изменеия в репозитериий и выполнить пуш
- перейти по ссылке http://gitlab-ci-ip/homework/example2/pipelines, статус выполнения отображен как "passed"

Задание со *:
- перейти в GCP
- выбрать ip-адрес автоматически созданной docker-machine (имя машины: [Название ветки git]-[id pipeline])
- убедится, что правила МЭ позволяют попасть на сервер по порту tcp/9292
- перейти по адресу + порт 9292, откроется тестируемое приложение reddit

- при запуске задачи  kill branch review в Gitlab-CI тестовое окружение удалится.

# 19. Homework-19. Monitoring-1

## 19.1 Что было сделано

- приведен в порядок репозиторий 8);
- создан и настроен docker-образ для prometheus:

задание со *, **:
- собран докер образ mongodb_exporter (за основу бралась версия 0.4.0 из репозитория percona https://github.com/percona/mongodb_exporter/tree/v0.4.0), prometheus настроен на сбор метрик с mongodb;
- Blackbox exporter (использовался готовы от prometheus :) ) прикручен к prometheus и настроен мониторинг работы http-сервисов приложения reddit;
- создан Makefile для автоматизации рутинных действий;

## 19.2 Как запустить проект
### 19.2.1 Base + *
Все действия выполняются в корне репозитория.
в makefile задать значения переменных:
- USER_NAME - имя пользователя для docker hub
- VM_NAME - имя создаваемой VM
- GOOGLE_PROJECT- название проекта в GCP

Далее:
- `cp docker/.env.example docker/.env` - при необходимости внести изменения в .env
- `make init` - создать docker-machine в GCP
- `eval $(docker-machine env VM_NAME)`, VM_NAME - имя созданного сервера
- `make app_start` - запустить созданные приложения

- чтобы пересобрать все образы и перезапустить их на сервере, выполнить: `make rebuild`

После окончания работы:
- `make destroy` - удалить созданный сервер docker-machine

## 19.3 Как проверить
- выполнить `docker-machine ip VM_NAME`
- перейти по адресу: http://docker-machine-ip:9292 - отобразиться запущенное приложение
- перейти по адресу: http://docker-machine-ip:9090 - отобразиться система мониторинга prometheus, в разделе Status --> Targets отображаются контролируемые сервисы
![](https://i.imgur.com/NcbwWFO.png)

# 20. Homework-20. Monitoring-2

## 20.1 Что было сделано

- установлены и настроены сервисы: cAdvisor, Grafana, AlertManger
- созданы дашборды и настроены графики для различных метрик
- настроена отправка алертов в канал Slack (https://devops-team-otus.slack.com/messages/C9KNXLWAY)

задание со *:
- обновлен Makefile для установки новых сервисов
- prometheus настроен для сбора нативных метрик docker (экспериментальный режим)
- настроена отправка алертов на email (gmail)

## 20.2 Как запустить проект ( Base + * )
Все действия выполняются в корне репозитория.
в makefile задать значения переменных:
- USER_NAME - имя пользователя для docker hub
- VM_NAME - имя создаваемой VM
- GOOGLE_PROJECT- название проекта в GCP

Далее:
- `cp docker/.env.example docker/.env` - при необходимости внести изменения в .env
- `make init` - создать docker-machine в GCP + правила МЭ
- `eval $(docker-machine env VM_NAME)`, VM_NAME - имя созданного сервера
- для файла `monitoring/alertmanager/config.yml` - задать аккаунт (google) + app-token
- `make build` - создать все контенеры
- `make push` - запушить все созданные контейнеры в docker hub
- `make start` - запустить приложение и сервисы мониторинга

- `make restart` - переапустить все контенеры, если некоторые из них пересоздавались через docker build

- чтобы пересобрать все образы и перезапустить их на сервере, выполнить: `make rebuild`

После окончания работы:
- `make destroy` - удалить созданный сервер docker-machine + созданные правила МЭ

NB! cAdvisor не работает при наличии контейнеров без тегов

## 20.3 Как проверить
- выполнить `docker-machine ip VM_NAME`
- запустить `make teststop`
- через 1-2 минуты в slack-канал и на почту придут сообщения о проблеме с сервисом post
- cAdvisor доступен по адресу http://docker-machine-ip:8080
- Grafana доступна по адресу http://docker-machine-ip:3000
- AlertManager доступен по адресу http://docker-machine-ip:9093
- Prometheus доступен по адресу http://docker-machine-ip:9090
	- во вкладке Alerts - отображаются настроенные алерты
	- во вкладке Targets - отображаются источники метрик

![](https://i.imgur.com/msWAYNr.png)

# 21. Homework-21. Logging-1

## 21.1 Что было сделано

- обновлен код приложения для интеграции с системой лонирования (fluentd, zipkin)
- создан файл docker-compose-logging.yml позволяюший установить компоненты системы логирования (fluentd, ELK, zipkin)
- проведены настройки fluentd, ELK

задание со *:
- в параметры фильтров fluentd добавлен код парсинга логов сервиса UI
- найдена проблема работоспособности сбойного сервиса (https://github.com/Artemmkin/bugged-code)

## 21.2 Как запустить проект ( Base + * )
Все действия выполняются в корне репозитория.
в makefile задать значения переменных:
- USER_NAME - имя пользователя для docker hub
- VM_NAME - имя создаваемой VM
- GOOGLE_PROJECT- название проекта в GCP
либо передавать их в качестве аргументов при запуске make, например:
`make init USER_NAME=user VM_NAME=logging GOOGLE_PROJECT=docker-012345`

Далее:
- `cp docker/.env.logging.example docker/.env` - создать файл с переменными окружения, в который при необходимости внести изменения;
- `make init` - создать docker-machine в GCP + правила МЭ;
- `eval $(docker-machine env VM_NAME)`, где VM_NAME - имя созданного сервера Docker-machine.

- `make build` - создать контенеры приложения (ui, post, comment)
- `make build_log` - создать контенеры системы логирования (fluentd)

- `make log_start` - запустить сервсиы логирования (fluentd, ElasticSearch, Kibana, Zipkin)
- `make app_start` - запустить приложение (ui, post, comment)

После окончания работы:
- `make destroy` - удалить созданный сервер docker-machine + созданные правила МЭ

## 21.3 Как проверить
- выполнить `docker-machine ip VM_NAME`
- Сервис Kibana доступен по адресу http://docker-machine-ip:5601
- Сервис Zipkin доступен по адресу http://docker-machine-ip:5601

# 22. Homework-22. Kubernetes-1

## 22.1 Что было сделано

- созданы файлы манифестов сервисов (post, ui, comment, mongo)
- развернут k8s по шагам описанным в https://github.com/kelseyhightower/kubernetes-the-hard-way

задание со *:
- создан плей-бук ansible для разворачивания k8s

## 22.2 Как запустить проект ( Base + * )

- Создать сервисную учетную запись в GCP с правами доступа к проекту docker-******;
- Выполнить `cd kubernetes\ansible`
- Сохранить файс с учетными данными GCP в credentials.json, пример: `gcloud iam service-accounts keys create credentials.json --iam-account k8s-service-account@docker-201818.iam.gserviceaccount.com`
- Установить локально необходимый софт для развертывания: `ansible-playbook 01-install-client-tools.yaml`.
- Запустить создание k8s в GCP: `02-kubernetes-the-hard-way.yaml`

## 22.3 Как проверить
Выполнить:
- `kubectl get componentstatuses` - отобразится состояние компонентов кластера
- `kubectl get nodes` - отобразится состояние рабоичх узлов

# 23. Homework-23. Kubernetes-2

## 23.1 Что было сделано

- созданы файлы манифестов (post, ui, comment, mongo), описание сервисов и неймспейсов
- приложение развернуто в окружении minikube и GKE 

![](https://i.imgur.com/cfVe8Gt.png)

задание со *:
- создан файл terraform для установки кластера kubernettes в GKE
- созданы файлы манифестов для сервиса kubernetes dashboard

## 23.2 Как запустить проект ( Base + * )

- `cd kubernetes\teraform`
- `terraform init`
- `terraform apply`
- перейти в GCP --> Kubernetes clusters --> Connect, выполнить конфигурацию kubectl
- создать неймспейс `kubectl apply -f ../reddit/dev-namespace.yml`
- выполнить деплой приложения reddit `kubectl apply -n dev -f ../reddit/`


## 23.3 Как проверить
Выполнить:
- с использованием следующих команд, получить значение ip + port опубликованного приложения:
	- `kubectl get nodes -o wide`
	- `kubectl describe service ui -n dev | grep NodePort`
- перейти по адресу и порту, на котором опубликовано приложение

# 24. Homework-24. Kubernetes-3

## 24.1 Что было сделано

- созданы файлы манифестов приложения reddit для настройки:
	- Ingress контроллера
	- TLS
	- LB
	- сетевых политик
	- хранилищ

задание со *:
- создан манифест (secret) для TLS-сертификата

## 24.2 Как запустить проект ( Base + * )

- `cd kubernetes\teraform`
- `terraform init`
- `terraform apply`
- перейти в GCP --> Kubernetes clusters --> Connect, выполнить конфигурацию kubectl
- создать неймспейс `kubectl apply -f ../reddit/dev-namespace.yml`
- выполнить деплой приложения reddit `kubectl apply -n dev -f ../reddit/`

## 24.3 Как проверить
Выполнить:
- получить значение ip port опубликованного приложения `kubectl get ingress -n dev | tail -n 1 | awk '{print $3}'`
- перейти по адресу на котором опубликовано приложение

# 25. Homework-25. Kubernetes-4

## 25.1 Что было сделано

- установлен и настроен Helm + Tiller
- созданы Charts на основе манифестов kubernetes
- с использовнием helm развернут Gitlab-CI, для которого:
	- создана группы и проекты
	- настроены пайплайны для сборки и деплоя приложения
задание со *:
- в пайплайны ui,post,comment добавлена возможность запуска деплоя при коммите в ветку master

## 25.2 Как запустить проект (Base)

### Базовая настройка

- `cd kubernetes\teraform`
- `terraform init`
- `terraform apply`
- перейти в GCP --> Kubernetes clusters --> Настройки кластера cluster --> Установить  Legacy authorization: Enable
- перейти в GCP --> Kubernetes clusters --> Connect, выполнить конфигурацию kubectl

### Helm
![](https://chocolatey.org/content/packageimages/kubernetes-helm.2.9.1.png)

- `kubectl apply -f kubernetes/Charts/tiller.yml`
- `helm init --service-account tiller`
- `kubectl get pods -n kube-system --selector app=helm` убедится в наличии пода helm

### Helm test deploy

- `helm install kubernetes/Charts/reddit --name test01`
- `helm ls; kubectl get pods` - убедиться в наличии задеплоенного приложения и нужных подов
- `kubectl get ingress` - дождаться (ждать долго) получения внешнего адреса, перейти на сайт приложения

### Gitlab
![](https://flowdocs.built.io/assets/blt99e09e809ca0ba6e/Gitlab-128.png)

**Перед установкой Gitlab ci убедитсья в отсутсвтии неиспользуемыех SSD-дисков иначе может не взлететь из-за превышения квот**

- `helm install --name gitlab kubernetes/Charts/gitlab-omnibus -f kubernetes/Charts/gitlab-omnibus/values.yaml`
- `kubectl get service -n nginx-ingress nginx` (ждать долго) получить адрес gitlab-ci и прописать его в /etc/hosts для gitlab-gitlab, staging, production
- Добавить группу fl64 и проекты ui,post,comment,reddit-deploy
- Добавить переменные для доступа на docker hub:
	- CI_REGISTRY_PASSWORD
	- CI_REGISTRY_USER
- Запушить код приложения последовательно в каждую ветку

Для задания со *:
- http://gitlab-gitlab/fl64/reddit-deploy/settings/ci_cd --> Pipeline triggers --> Задать имя триггера и добавить его.
- Токен триггера добавить в переменную DEPLOY_TOKEN группы fl64

## 25.3 Как проверить

#### Для Helm test deploy
- `kubectl get ingress`
- перейти в браузере по указанному адресу для задеплоенного приложения
Удлаить приложение:
- `helm delete --purge test01`

#### Для Gitlab + *
- запушить изменения последовательно в ui,post,commit
- отработают пайплайны для соотвествующих проектов, автоматически отработает пайплайн reddit-deploy (для задания со *)
- тестовые приложения доступны по ссылке:
	- http://staging
	- http://profuction

# 26. Homework-26. Kubernetes-5

## 26.1 Что было сделано

- установлен prometheus и настроен сбор метрик для k8s, метрики также отображаются для каждого микросервиса приложения (ui, post, comment)
- установлена grafana + настроены дэшборды для отображения статистики приложения. отображение графиков возможно для разных окружений
	- в описании ДЗ значение параметра - namespace, по факту - kubernetes_namespace
- установлен и настроен EFK для сбора логов приложения

задание со * (50/50):
- настройка alertmanager - не выполнялась
- создан chart для установки EFK

## 26.2 Как запустить проект (Base)

### 26.2.1 Базовая настройка

#### Установка кластера
- `cd kubernetes\teraform`
- `terraform init`
- `terraform apply`
- `gcloud container clusters get-credentials cluster --zone europe-west4-a --project docker-XXXXXX`, где docker-XXXXXX - название проекта

#### Настрйока HELM
- `kubectl apply -f kubernetes/reddit/tiller.yml`
- `helm init --service-account tiller`

#### Установка nginx ingress
- `helm install stable/nginx-ingress --name nginx`
- `echo $(kubectl get svc | grep LoadBalancer | awk '{print $4}')  reddit reddit-prometheus reddit-grafana reddit-non-prod production reddit-kibana staging prod >> /etc/hosts`

#### Установить prometheus
- `helm upgrade prom kubernetes/Charts/prometheus -f kubernetes/Charts/prometheus/custom_values.yaml --install`

#### Запуск приложения
```
helm upgrade reddit-test kubernetes/Charts/reddit --install
helm upgrade production --namespace production kubernetes/Charts/reddit --install
helm upgrade staging --namespace staging kubernetes/Charts/reddit --install
```
#### Установка и запуск grafana
- `helm upgrade grafana kubernetes/Charts/grafana -f kubernetes/Charts/grafana/custom_values.yaml --install`
- импортировать шаблоны дэшбордов из kubernetes/Grafana_dashboards

### 26.2.2 *

#### Установка и запуск EFK
`helm upgrade grafana kubernetes/Charts/efk -f kubernetes/Charts/efk/custom_values.yaml --install`

## 26.3 Как проверить

- сервис prometheus доступен по адресу http://reddit-prometheus, настроен сбор метрик для:
	- k8s
	- ui, comment, post
- сервис grafana доступен по адресу http://reddit-grafana
- сервис EFK доступен по адресу http://reddit-kibana



















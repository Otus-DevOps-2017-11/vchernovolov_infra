# vchernovolov_infra

# ДЗ-05

## Подключение к someinternalhost в одну команду:

ssh -i ~/.ssh/appuser -At appuser@35.189.89.242 ssh someinternalhost

## Конфигурация
Хост bastion          => внешний IP 35.189.89.242, внутренний IP 10.154.0.2
Хост someinternalhost => внутренний IP 10.154.0.3



# ДЗ-06

## Команда gcloud создания инстанса reddit-app:

```
gcloud compute instances create reddit-app2\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --zone=europe-west2-a \
  --metadata startup-script-url=https://raw.githubusercontent.com/Otus-DevOps-2017-11/vchernovolov_infra/Infra-2/startup.sh
```



# ДЗ-07

## Валидация конфигурации создаваемого образа:

```
packer validate ubuntu16.json
```

## Создание образа, указывая значения отдельных переменных:

```
packer build \
  -var 'project_id=affable-enigma-189317' \
  -var 'source_image_family=ubuntu-1604-lts' \
  -var 'machine_type=f1-micro' \
  ubuntu16.json
```

## Создание образа, указывая файл variables.json, заполненный в соответствии с файлом-примером variables.json.example:

```
packer build -var-file=variables.json ubuntu16.json
```

# ДЗ-08 "Практика IaC с использованием Terraform"

## Создан файл конфигурации для terraform
```
main.tf
```
Задано определение:
  - провайдера - ```google```;
  - ресурса-инстанса - ```google_compute_instance```;
  - ресурса-фаервола - ```google_compute_firewall```;
  - для ресурса-инстанса определены провизионеры (```provisioner```).


## Конфигурационный файл ```main.tf``` параметризирован
В файле ```terraform.tfvars.example``` дано описание примера для переменных конфигурации.

## Реализован вывод ip-созданного инстанса
Данная настройка указана в файле ```output.tf```

## Настройки для deploy/запуска puma-service вынесены в конфигурационные файлы
Файлы конфигурации расположены в ```/terraform/files```


## Перед созданием инстанса проверям план выполнения terraform
```
terraform plan
```

## Создание инстанса, deploy, запуск производим коммандой
```
terraform apply
```


# ДЗ-09 "Принципы организации инфраструктурного кода (terraform)"

## Создано добавлены ресурсы - правило файервола firewall_ssh, ip сервера app

## Образ для `packer` разделен на 2:
 `reddit-db-base` - образ с БД
 `reddit-app-base` - образ с приложением

## Конфиг main.tf разделен на 2:
 `app.tf` - конфигурация для деплоя образа приложения
 `db.tf` - конфигурация для деплоя образа БД

## В файл vpc.tf вынесено правило файервола firewall_ssh

## Конфигурация реализована с применением модулей
В папку `modules` вынесены app - приложение, db - БД, vpc - ресурсы VPC
В каждом модуле определены соответствующие `*.tf` конфигурационные файлы

## Файлы конфигурации пареметризированы

## Использован результат`outputs.tf`
Реализовано определение зависимых ресурсов (ресурсы одного модуля определены на основе вычисляемых ресурсов другого модуля)

## Применено переиспользование модулей
Реализованы окружения `Prod` & `Stage` (преднастроенные конфигурации/реализации конфигурации)

## Приведен пример работы с рееестром модулей
Пример реализации - `storage-bucket.tf`

## Задание со `*` - сделаны настройки для деплоя и запуска `app (puma service)`
В конфигурацию `app`, `db` добавлены `provisioner`'s:
- передача приложению `app` адреса БД `db`;
- в конфигурации запуска на `db` (mongod.conf) задан `bindIp`, разрешающий подключения извне


# ДЗ-10 "Знакомство с Ansible"

## Установлен `ansible`
Перед установкой `ansible` был установлен пакетный менеждер `pip`.
Далее - установлен `ansible` командой:
```
sudo pip install -r requirements.txt
```

## Запущены VMs (предыдущее ДЗ) окружения `stage`
Получаем внешние ip инстансов app, db:
```
terraform show
```

## В `inventory` файле описаны хосты, группы хостов
Проверка возможности `ansible` управлять хостами (доступ, команда `ping`)
```
ansible appserver -i ./inventory -m ping
```
```
ansible dbserver -i ./inventory -m ping
```

## В конфиг файл `ansible.cfg` вынесены общие для инстаносов настройки
- путь к`inventory` файлу, его наименование;
- пользователь (под которым подключаемся к инстансам [хостам]);
- путь к файлу приватного ключа.

## `inventory` файл реализован в формате `*.yml`
Проверка, команда `ping`:
```
ansible all -m ping -i inventory.yml
```

# ДЗ-11 "Деплой и управление конфигурацией с Ansible"

## Создано несколько плейбуков для настройки и деплоя инстансов db и app
`ansible/reddit_app_one_play.yml` - плейбуки для db и app в одном `play-book`, тегами разграничены db, app, deploy<br>
`ansible/reddit_app_multiple_plays.yml` - также плейбуки для настройки БД и приложения в одном файле, но разные `play-book`, тегами разграничены db, app, deploy


## Настройки конфигов БД шаблонизированы (ansible/templates)
- `ansible/templates/mongod.conf.j2` - конфиг mongodb
- `ansible/templates/db_config.j2` - файл, содержащий переменные, необходимые для приложения (`puma.service`)

## Unit файл приложения `puma.service` вынесен в ansible/files
Через EnvironmentFile получили доступ к БД (DATABASE_URL)

## Проверка и запуск плейбуков reddit_app_one_play, reddit_app_multiple_plays
db
```
ansible-playbook reddit_app_one_play.yml --tags db-tag --check
ansible-playbook reddit_app_one_play.yml --tags db-tag
```
```
ansible-playbook reddit_app_multiple_plays.yml --tags db-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags db-tag
```

app
```
ansible-playbook reddit_app_one_play.yml --tags app-tag --check
ansible-playbook reddit_app_one_play.yml --tags app-tag
```
```
ansible-playbook reddit_app_multiple_plays.yml --tags app-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags app-tag
```

deploy
```
ansible-playbook reddit_app_one_play.yml --tags deploy-tag --check
ansible-playbook reddit_app_one_play.yml --tags deploy-tag
```
```
ansible-playbook reddit_app_multiple_plays.yml --tags deploy-tag --check
ansible-playbook reddit_app_multiple_plays.yml --tags deploy-tag
```

## Далее созданы плейбуки в отдельных файлых для db, app, deploy
- `ansible/db.yml`
- `ansible/app.yml`
- `ansible/deploy.yml`

## Затем все 3 плейбука (db, app, deploy) были собраны в одном - `site.yml`
```
- import_playbook: db.yml
- import_playbook: app.yml
- import_playbook: deploy.yml
```

Проверка и запуск плейбука site.yml
```
ansible-playbook site.yml --check
```
```
ansible-playbook site.yml
```

## Реализованы плейбуки для `provisioner`s образов `packer`
- `ansible/packer_db.yml`
- `ansible/packer_app.yml`

Данные плейбуки указаны в секции `provisioner` файлов сборки образов
- `packer/db.json`
- `packer/app.json`

После чего были пересозданы образы, пересозданы инстансы окружения `stage` и
сконфигурированы инстансы db & app
```
ansible-playbook site.yml --check
```
```
ansible-playbook site.yml
```

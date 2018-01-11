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

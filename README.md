# vchernovolov_infra

# ДЗ-05

## Подключение к someinternalhost в одну команду:

ssh -i ~/.ssh/appuser -At appuser@35.189.89.242 ssh someinternalhost

## Конфигурация
Хост bastion          => внешний IP 35.189.89.242, внутренний IP 10.154.0.2
Хост someinternalhost => внутренний IP 10.154.0.3



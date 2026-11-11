# ansible_terraform

Учебный проект по Terraform: виртуальные машины в Proxmox VE из cloud-образа
Debian 13. Ansible-часть вынесена в отдельный проект `deploy_ansible`:
Terraform создаёт ВМ, Ansible их настраивает.

> **Это личный проект, который я делаю только в рамках обучения.**
> Terraform работает с реальным Proxmox. Проект не претендует на
> production-ready: конфиги упрощены, а решения принимались по ходу изучения
> Terraform, Proxmox и Linux.

## Что внутри

| Ресурс | Что делает |
|---|---|
| `proxmox_download_file` | скачивает cloud-образ Debian 13 |
| `proxmox_virtual_environment_vm.debian_template` | создаёт шаблон ВМ с cloud-init |
| `proxmox_virtual_environment_vm.debian_clone` | linked-клон шаблона для nginx |
| `proxmox_virtual_environment_vm.whings_server` | полный клон под Pterodactyl/Whings |
| `proxmox_virtual_environment_vm.dev_server` | полный клон для dev-сервера |
| `output` | IPv4-адреса созданных ВМ |

Провайдер — [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest)
версии `0.118.0`. Все ВМ создаются из одного шаблона, а параметры (ядра, RAM,
диск, адрес, теги) задаются переменными.

## Структура

```
terraform/
  main.tf                 # провайдер, шаблон и три клона
  variables.tf            # переменные
  terraform.tfvars        # рабочие значения (без секретов)
  terraform.tfvars.example
  .tflint.hcl             # правила TFLint
  tests/
    vm_plan.tftest.hcl    # проверки плана без реального Proxmox
    fixtures/             # тестовые ключи
.pre-commit-config.yaml
lint.ps1
.github/workflows/terraform.yml
```

## Настройка

`terraform.tfvars.example` — шаблон для новой среды. Рабочие значения лежат в
`terraform.tfvars`, который уже добавлен в репозиторий: в нём только параметры
ВМ, без токенов и ключей.

Что нужно заполнить:

- `proxmox_endpoint`, `proxmox_api_token` — доступ к API Proxmox;
- `private_key`, `vm_user_key` — пути к приватному и публичному SSH-ключам:
  Terraform читает их через `file()`, поэтому в переменных указывается путь,
  а не содержимое ключа;
- `node_name`, `node_address`, `datastore_id` — где создавать ВМ;
- параметры `vm_id_*` — ID, имена, CPU, RAM, диски и адреса ВМ.

## Запуск

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Состояние хранится в local backend по пути
`/home/skuf/terraform-state/terraform.tfstate`. Каталог должен существовать до
первого `terraform apply`; в репозиторий state не попадает.

## Секреты

Токен Proxmox, SSH-ключи и адрес API **не хранятся в репозитории**. В GitHub
Actions они передаются через `TF_VAR_*` из GitHub Secrets:

| Секрет | Переменная |
|---|---|
| `PROXMOX_ENDPOINT` | `proxmox_endpoint` |
| `PROXMOX_API_TOKEN` | `proxmox_api_token` |
| `PRIVATE_KEY` | `private_key` |
| `VM_USER_KEY` | `vm_user_key` |
| `PROXMOX_USER`, `PROXMOX_INSECURE` | доступ к API |
| `NODE_NAME`, `NODE_ADDRESS`, `NODE_PORT` | параметры ноды |
| `DATASTORE_ID`, `ISO_DATASTORE_ID` | хранилища |
| `VM_DNS_LIST`, `VM_USER_ACCOUNT` | параметры cloud-init |

Секреты читаются только на шагах `plan` и `apply`; проверки конфигов
(`fmt`, `validate`, `tflint`, `test`) работают без них.

## Проверки

```powershell
.\lint.ps1
```

Скрипт запускает те же проверки, что и CI:

- `pre-commit` (если установлен) — `terraform fmt`, `terraform validate`,
  `terraform tflint`;
- `terraform fmt -check -recursive -diff`;
- `terraform init -backend=false`;
- `terraform validate`;
- `tflint --init` и `tflint`;
- `terraform test`.

Если `terraform` и `tflint` не установлены, их можно положить локально:

```powershell
.\tools\install-tools.ps1
.\lint.ps1
```

Скрипт скачивает бинарники в `.tools/` (каталог в git не попадает) и создаёт
локальный `.terraformrc` с зеркалом провайдеров Yandex Cloud — это помогает,
когда `registry.terraform.io` недоступен. Если у тебя уже есть свой прокси или
зеркало, удали `.terraformrc` или задай `TF_CLI_CONFIG_FILE` вручную.
`lint.ps1` сам находит `.tools`, менять `PATH` не нужно.

`pre-commit` необязателен: без него проверки выполняются напрямую. Чтобы
включить хуки перед коммитом:

```bash
pre-commit install
```

## Тесты

Тесты лежат в `terraform/tests/` и запускаются обычным `terraform test` из
каталога `terraform/`:

```bash
cd terraform
terraform init -backend=false
terraform test
```

В тестах используется `mock_provider "proxmox"`: Terraform не подключается к
Proxmox и не создаёт реальные ВМ, но строит план и проверяет атрибуты ресурсов.
Поэтому тесты не требуют токенов и не могут ничего сломать.

Что проверяется:

- шаблон создаётся с `template = true`, нужными ядрами, RAM и диском;
- nginx-нода остаётся linked-клоном, остальные — полными;
- у клонов совпадают `vm_id`, RAM, ballooning, адреса и теги;
- output'ы возвращают IPv4-адрес из `ipv4_addresses`.

Тест можно дополнить новым блоком `run` и `assert`:

```hcl
run "my_check" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_vm.dev_server.cpu[0].cores == 2
    error_message = "У dev-сервера должно быть 2 ядра."
  }
}
```

Тесты требуют Terraform 1.7+ (это зафиксировано в `required_version`).
`mock_provider` не отменяет `terraform init`: плагин провайдера всё равно
нужно скачать один раз.

## CI

Workflow [`.github/workflows/terraform.yml`](.github/workflows/terraform.yml)
запускается на push в `main` и на pull request:

1. `terraform fmt -check -recursive`;
2. `terraform init` и `terraform validate`;
3. `tflint`;
4. `terraform test`;
5. `terraform plan`;
6. `terraform apply` — только для push в `main`.

Проверки и тесты не используют секреты, поэтому их можно безопасно запускать
на pull request'ах.

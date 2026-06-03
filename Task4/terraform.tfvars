# ============================================================================
# Значения переменных. Замените плейсхолдеры на свои перед `terraform apply`.
# ВНИМАНИЕ: файл может содержать чувствительные данные — не коммитьте реальные
# значения cloud_id/folder_id/ключей в публичный репозиторий.
# ============================================================================

# --- Аутентификация и расположение (получаются вручную в консоли Yandex Cloud)
service_account_key_file = "key.json"
cloud_id                 = "b1gxxxxxxxxxxxxxxxxx"
folder_id                = "b1gyyyyyyyyyyyyyyyyy"
zone                     = "ru-central1-a"

project = "future-2-0"

# --- Сеть
public_subnet_cidr  = "10.10.1.0/24"
private_subnet_cidr = "10.10.2.0/24"
allowed_ssh_cidr    = "0.0.0.0/0" # рекомендуется заменить на свой офисный IP/32

# --- Образ и экономичность
vm_image_family = "ubuntu-2204-lts"
core_fraction   = 20

# --- Bastion
bastion_cores        = 2
bastion_memory_gb    = 2
bastion_boot_disk_gb = 20

# --- Узлы платформы данных
app_node_count   = 2
app_cores        = 2
app_memory_gb    = 4
app_boot_disk_gb = 20
app_data_disk_gb = 50

# --- Доступ
ssh_public_key_path = "~/.ssh/id_rsa.pub"

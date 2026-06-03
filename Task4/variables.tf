# ============================================================================
# Переменные инфраструктуры «Будущее 2.0» (облачный фундамент, этап 1 роадмапа)
# ============================================================================

# ---- Аутентификация и расположение (создаётся вручную, см. justification.md) -
variable "service_account_key_file" {
  description = "Путь к JSON-ключу сервисного аккаунта Yandex Cloud"
  type        = string
}

variable "cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога (folder), где разворачивается инфраструктура"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "project" {
  description = "Префикс имён ресурсов"
  type        = string
  default     = "future-2-0"
}

# ---- Сеть ------------------------------------------------------------------
variable "public_subnet_cidr" {
  description = "CIDR публичной подсети (bastion / точка входа)"
  type        = string
  default     = "10.10.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR приватной подсети (узлы платформы данных, выход в интернет через NAT)"
  type        = string
  default     = "10.10.2.0/24"
}

variable "allowed_ssh_cidr" {
  description = "CIDR, с которого разрешён SSH к bastion (рекомендуется сузить до офисного IP)"
  type        = string
  default     = "0.0.0.0/0"
}

# ---- Образ ВМ --------------------------------------------------------------
variable "vm_image_family" {
  description = "Семейство образа загрузочного диска"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU (20 — экономно для теста, 100 — продакшен)"
  type        = number
  default     = 20
}

# ---- Bastion (публичный узел) ----------------------------------------------
variable "bastion_cores" {
  type        = number
  default     = 2
}

variable "bastion_memory_gb" {
  type        = number
  default     = 2
}

variable "bastion_boot_disk_gb" {
  type        = number
  default     = 20
}

# ---- Узлы платформы данных (приватные) -------------------------------------
variable "app_node_count" {
  description = "Количество узлов платформы данных (масштабирование изменением одного числа)"
  type        = number
  default     = 2
}

variable "app_cores" {
  type        = number
  default     = 2
}

variable "app_memory_gb" {
  type        = number
  default     = 4
}

variable "app_boot_disk_gb" {
  type        = number
  default     = 20
}

variable "app_data_disk_gb" {
  description = "Размер дополнительного диска данных на каждый узел"
  type        = number
  default     = 50
}

# ---- Доступ ----------------------------------------------------------------
variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу для доступа на ВМ"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

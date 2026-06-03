# ============================================================================
# Облачный фундамент «Будущее 2.0» — IaaS на Yandex Cloud (Terraform)
# Реализует этап 1 роадмапа (Task3): сеть, NAT, security group, ВМ, диски.
# ============================================================================

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

# ---- Образ загрузочного диска (data source) --------------------------------
data "yandex_compute_image" "ubuntu" {
  family = var.vm_image_family
}

# ============================================================================
# Сеть: VPC, публичная и приватная подсети, NAT-шлюз, таблица маршрутизации
# ============================================================================
resource "yandex_vpc_network" "this" {
  name        = "${var.project}-net"
  description = "Сеть облачного фундамента Будущее 2.0"
}

# NAT-шлюз для исходящего трафика приватной подсети
resource "yandex_vpc_gateway" "nat" {
  name = "${var.project}-nat-gw"
  shared_egress_gateway {}
}

# Таблица маршрутизации: весь исходящий трафик приватной подсети — через NAT
resource "yandex_vpc_route_table" "private" {
  name       = "${var.project}-private-rt"
  network_id = yandex_vpc_network.this.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

# Публичная подсеть — bastion / точка входа (прямой выход в интернет)
resource "yandex_vpc_subnet" "public" {
  name           = "${var.project}-public"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

# Приватная подсеть — узлы платформы данных (выход в интернет только через NAT)
resource "yandex_vpc_subnet" "private" {
  name           = "${var.project}-private"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.private_subnet_cidr]
  route_table_id = yandex_vpc_route_table.private.id
}

# ============================================================================
# Security group: SSH на bastion, свободный трафик внутри, исходящий — наружу
# ============================================================================
resource "yandex_vpc_security_group" "main" {
  name        = "${var.project}-sg"
  network_id  = yandex_vpc_network.this.id
  description = "Базовые правила доступа для узлов фундамента"

  ingress {
    protocol       = "TCP"
    description    = "SSH с разрешённого CIDR"
    port           = 22
    v4_cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    protocol          = "ANY"
    description       = "Любой трафик внутри security group (межузловое взаимодействие)"
    predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "Любой исходящий трафик"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ============================================================================
# Bastion: публичный узел доступа (публичный IP через NAT)
# ============================================================================
resource "yandex_compute_instance" "bastion" {
  name        = "${var.project}-bastion"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = var.bastion_cores
    memory        = var.bastion_memory_gb
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.bastion_boot_disk_gb
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.main.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# ============================================================================
# Узлы платформы данных: приватные ВМ + дополнительный диск данных на каждую
# ============================================================================
resource "yandex_compute_disk" "data" {
  count = var.app_node_count
  name  = "${var.project}-data-${count.index}"
  zone  = var.zone
  size  = var.app_data_disk_gb
  type  = "network-ssd"
}

resource "yandex_compute_instance" "app" {
  count       = var.app_node_count
  name        = "${var.project}-app-${count.index}"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = var.app_cores
    memory        = var.app_memory_gb
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.app_boot_disk_gb
      type     = "network-ssd"
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.data[count.index].id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.main.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

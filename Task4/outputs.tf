# ============================================================================
# Ключевые параметры созданной инфраструктуры
# ============================================================================

output "network_id" {
  description = "ID созданной VPC-сети"
  value       = yandex_vpc_network.this.id
}

output "nat_gateway_id" {
  description = "ID NAT-шлюза для приватной подсети"
  value       = yandex_vpc_gateway.nat.id
}

output "public_subnet_id" {
  description = "ID публичной подсети"
  value       = yandex_vpc_subnet.public.id
}

output "private_subnet_id" {
  description = "ID приватной подсети"
  value       = yandex_vpc_subnet.private.id
}

output "bastion_public_ip" {
  description = "Публичный IP bastion-узла (точка входа по SSH)"
  value       = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "bastion_internal_ip" {
  description = "Внутренний IP bastion-узла"
  value       = yandex_compute_instance.bastion.network_interface.0.ip_address
}

output "app_nodes_internal_ips" {
  description = "Внутренние IP узлов платформы данных"
  value       = [for vm in yandex_compute_instance.app : vm.network_interface.0.ip_address]
}

output "app_data_disk_ids" {
  description = "ID дисков данных, подключённых к узлам платформы"
  value       = [for d in yandex_compute_disk.data : d.id]
}

output "ssh_to_bastion" {
  description = "Готовая команда для подключения к bastion"
  value       = "ssh ubuntu@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"
}

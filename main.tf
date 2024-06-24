# some examples:
# - https://github.com/grimwm/idbm/blob/f526d509c1537e5050cc3f5974689837589367b5/iac/tf/main.tf

# tofu init
terraform {
  required_providers {
    # https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {
  type = string
  sensitive = true
}
variable "do_monitoring_email" {
  type = string
}
variable "do_monitoring_slack_webhook" {
  type = string
  sensitive = false # TODO: sensitive = true
}

provider "digitalocean" {
  token = var.do_token
}
# doctl projects list
# tofu import digitalocean_project.myproject 608255c8-7f7f-407d-bf53-ef749ce89c14
resource "digitalocean_project" "myproject" {
  name = "Project D3strukt0r"
  description = "All my projects"
  purpose = "Web Application"
  environment = "Production"
  is_default = true
  resources = [
    digitalocean_droplet.main.urn,
    digitalocean_volume.main.urn,
  ]
}
# doctl compute droplet list
# tofu import digitalocean_droplet.main 375424082
resource "digitalocean_droplet" "main" {
  image = "ubuntu-22-04-x64"
  name = "prod-de"
  region = "fra1"
  size = "s-2vcpu-4gb"
  backups = true
  ipv6 = true
  monitoring = true
  volume_ids = [digitalocean_volume.main.id]
  vpc_uuid = digitalocean_vpc.main.id
}
# doctl compute volume list
# tofu import digitalocean_volume.main b28e1427-6da5-11ee-b7ea-0a58ac14d86d
resource "digitalocean_volume" "main" {
  region = "fra1"
  name = "volume-fra1-01"
  size = 100
  #initial_filesystem_type = "ext4"
  #description = "an example volume"
}
# doctl compute firewall list
# tofu import digitalocean_firewall.ssh 2f8c32b2-b051-4517-9775-c1f12fbe1da0
# tofu import digitalocean_firewall.email 3954180e-0234-459f-9b4d-68bedf537ca4
# tofu import digitalocean_firewall.web 566a8788-74ea-48fd-8ab8-3cb80e999e41
resource "digitalocean_firewall" "email" {
  name = "Email"
  droplet_ids = [digitalocean_droplet.main.id]

  inbound_rule {
    protocol = "tcp"
    port_range = "110"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol = "tcp"
    port_range = "143"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol = "tcp"
    port_range = "25"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol = "tcp"
    port_range = "465"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol = "tcp"
    port_range = "587"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol = "tcp"
    port_range = "993"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol = "tcp"
    port_range = "995"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol = "udp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
resource "digitalocean_firewall" "ssh" {
  name = "SSH"
  droplet_ids = [digitalocean_droplet.main.id]

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}
resource "digitalocean_firewall" "web" {
  name = "Web"
  droplet_ids = [digitalocean_droplet.main.id]

  inbound_rule {
    protocol = "tcp"
    port_range = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol = "udp"
    port_range = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol = "tcp"
    port_range = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol = "udp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
# doctl vpcs list
# tofu import digitalocean_vpc.main 699e0b9a-7589-41ec-8420-03a4c1f65330
resource "digitalocean_vpc" "main" {
  name     = "default-fra1"
  region   = "fra1"
  ip_range = "10.114.0.0/20"
}
# doctl monitoring alert list
# tofu import digitalocean_monitor_alert.storage_alert bb96aa22-1e9b-4911-b2a8-c8cb0d02b91c
# tofu import digitalocean_monitor_alert.memory_alert 9271a11b-3b1a-4b6b-9b4d-f3c804e0d3c6
resource "digitalocean_monitor_alert" "storage_alert" {
  alerts {
    email = [var.do_monitoring_email]
    slack {
      channel = "#digitalocean-alerts"
      url = var.do_monitoring_slack_webhook
    }
  }
  window = "5m"
  type = "v1/insights/droplet/disk_utilization_percent"
  compare = "GreaterThan"
  value = 80
  enabled = true
  #entities = [digitalocean_droplet.main.id] # all droplets
  description = "Disk Utilization Percent is running high"
}
resource "digitalocean_monitor_alert" "memory_alert" {
  alerts {
    email = [var.do_monitoring_email]
    slack {
      channel = "#digitalocean-alerts"
      url = var.do_monitoring_slack_webhook
    }
  }
  window = "5m"
  type = "v1/insights/droplet/memory_utilization_percent"
  compare = "GreaterThan"
  value = 90
  enabled = true
  #entities = [digitalocean_droplet.main.id] # all droplets
  description = "Memory Utilization Percent is running high"
}

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
# https://cloud.digitalocean.com/account/api/tokens/new?&i=cd47c3
# with "Full Access" scope
# TODO: Figure out what to set in "Custom Scopes" instead
variable "do_token" {
  type = string
  description = "DigitalOcean API token with Full Access scope"
  sensitive = true
  validation {
    condition = can(regex("^dop_v1_[a-f0-9]{64}$", var.do_token))
    error_message = "The do_token must be a valid DigitalOcean API token (`dop_v1_x`) with Full Access scope."
  }
}
variable "pvt_key" {
  type = string
  description = "Path to the private key file"
  #sensitive = true
  validation {
    condition = can(file(var.pvt_key))
    error_message = "The pvt_key must be a valid path to the private key file."
  }
}
variable "do_monitoring_email" {
  type = string
  description = "Email address to receive monitoring alerts"
  validation {
    condition = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.do_monitoring_email))
    error_message = "The do_monitoring_email must be a valid email address."
  }
}
variable "do_monitoring_slack_webhook" {
  type = string
  description = "Slack webhook URL to receive monitoring alerts"
  #sensitive = true
  validation {
    condition = can(regex("^https://hooks.slack.com/services/[A-Z0-9]+/[A-Z0-9]+/[a-zA-Z0-9]+$", var.do_monitoring_slack_webhook))
    error_message = "The do_monitoring_slack_webhook must be a valid Slack webhook URL (https://hooks.slack.com/services/x/x/x)."
  }
}

provider "digitalocean" {
  token = var.do_token
}
# doctl compute ssh-key list
# tofu import digitalocean_ssh_key.d3strukt0r 39443066
data "digitalocean_ssh_key" "d3strukt0r" {
  name = "D3strukt0r"
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
  #ssh_keys = [
  #  data.digitalocean_ssh_key.d3strukt0r.id
  #]

  #connection {
  #  host = self.ipv4_address
  #  user = "root"
  #  type = "ssh"
  #  private_key = file(var.pvt_key)
  #  timeout = "2m"
  #}

  #provisioner "remote-exec" {
  #  inline = [
  #    "export PATH=$PATH:/usr/bin",
  #    # install nginx
  #    "sudo apt update",
  #    "sudo apt install -y nginx"
  #  ]
  #}
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
# doctl monitoring uptime list
# tofu import digitalocean_uptime_check.ping 68300e8f-39a4-4ea8-89a7-baa1ee3b5ef5
resource "digitalocean_uptime_check" "ping" {
  name    = "Check Ping Container"
  target  = "https://ping.d3strukt0r.dev/"
  regions = ["eu_west", "se_asia", "us_east", "us_west"]
}

#output "droplet_ip_addresses" {
#  value = {
#    for droplet in digitalocean_droplet.main:
#    droplet.name => droplet.ipv4_address
#  }
#}

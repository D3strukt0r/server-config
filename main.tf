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
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.36"
    }
    namecheap = {
      source  = "namecheap/namecheap"
      version = "~> 2.0"
    }
  }

  #backend "http" {
  #  address        = "https://opentofu-state.d3strukt0r.dev"
  #  lock_address   = "https://opentofu-state.d3strukt0r.dev"
  #  unlock_address = "https://opentofu-state.d3strukt0r.dev"
  #  username       = "admin"
  #  password       = "" # or use TF_HTTP_PASSWORD
  #}

  ## https://ruben-rodriguez.github.io/posts/minio-s3-terraform-backend/
  #backend "s3" {
  #  bucket = "default" # Name of the S3 bucket
  #  endpoints = {
  #    s3 = "https://minio-opentofu-state.d3strukt0r.dev" # Minio endpoint
  #  }
  #  key = "terraform.tfstate" # Name of the tfstate file

  #  access_key = "xxxxxxxxxxxx" # Access and secret keys
  #  secret_key = "xxxxxxxxxxxxxxxxxxxxxx"

  #  region                      = "main" # Region validation will be skipped
  #  skip_credentials_validation = true   # Skip AWS related checks and validations
  #  skip_requesting_account_id  = true
  #  skip_metadata_api_check     = true
  #  skip_region_validation      = true
  #  use_path_style              = true # Enable path-style S3 URLs (https://<HOST>/<BUCKET>
  #  # https://developer.hashicorp.com/terraform/language/settings/backends/s3#use_path_style
  #  # https://opentofu.org/docs/language/settings/backends/s3/#s3-state-storage
  #}

  #encryption {
  #  method "unencrypted" "migrate" {}
  #  key_provider "pbkdf2" "mykey" {
  #    passphrase = "changeme!"
  #  }
  #  key_provider "openbao" "my_bao" {
  #    key_name = "test-key"
  #    token    = "token-from-bao"
  #    address  = "https://openbao.d3strukt0r.dev"
  #  }
  #  method "aes_gcm" "new_method" {
  #    keys = key_provider.pbkdf2.mykey
  #    #keys = key_provider.openbao.my_bao
  #  }
  #  state {
  #    #method = method.unencrypted.migrate
  #    method = method.aes_gcm.new_method
  #    # Run "tofu apply"
  #    # then uncomment:
  #    #enforced = true
  #  }
  #  remote_state_data_sources {
  #    default {
  #      method = method.aes_gcm.new_method
  #    }
  #  }
  #}
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
# https://cloud.digitalocean.com/account/api/tokens/new?&i=cd47c3
# with "Full Access" scope
# TODO: Figure out what to set in "Custom Scopes" instead
variable "do_token" {
  type        = string
  description = "DigitalOcean API token with Full Access scope"
  sensitive   = true
  validation {
    condition     = can(regex("^dop_v1_[a-f0-9]{64}$", var.do_token))
    error_message = "The do_token must be a valid DigitalOcean API token (`dop_v1_x`) with Full Access scope."
  }
}
variable "pvt_key" {
  type        = string
  description = "Path to the private key file"
  #sensitive = true
  validation {
    condition     = fileexists(var.pvt_key)
    error_message = "The pvt_key must be a valid path to the private key file."
  }
}
variable "do_monitoring_email" {
  type        = string
  description = "Email address to receive monitoring alerts"
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.do_monitoring_email))
    error_message = "The do_monitoring_email must be a valid email address."
  }
}
variable "do_monitoring_slack_webhook" {
  type        = string
  description = "Slack webhook URL to receive monitoring alerts"
  #sensitive = true
  validation {
    condition     = can(regex("^https://hooks.slack.com/services/[A-Z0-9]+/[A-Z0-9]+/[a-zA-Z0-9]+$", var.do_monitoring_slack_webhook))
    error_message = "The do_monitoring_slack_webhook must be a valid Slack webhook URL (https://hooks.slack.com/services/x/x/x)."
  }
}
# https://dash.cloudflare.com/profile/api-tokens
# Create Custom Token with "Zone.DNS:Edit" permissions
variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token"
  sensitive   = true
  validation {
    condition     = can(regex("^[a-zA-Z0-9_]{40}$", var.cloudflare_api_token))
    error_message = "The cloudflare_api_token must be a valid Cloudflare API token."
  }
}
# https://ap.www.namecheap.com/settings/tools/apiaccess/
# Also add the IP address of the machine running Terraform to the whitelist
# https://ap.www.namecheap.com/settings/tools/apiaccess/whitelisted-ips
variable "namecheap_api_key" {
  type        = string
  description = "Namecheap API key"
  sensitive   = true
  validation {
    condition     = can(regex("^[a-f0-9]{32}$", var.namecheap_api_key))
    error_message = "The namecheap_api_key must be a valid Namecheap API key."
  }
}

provider "digitalocean" {
  token = var.do_token
}
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
provider "namecheap" {
  user_name = "D3strukt0r2"
  api_user  = "D3strukt0r2"
  api_key   = var.namecheap_api_key
}

#import {
#  to = digitalocean_ssh_key.d3strukt0r
#  id = "39443066"
#}
data "digitalocean_ssh_key" "d3strukt0r" {
  name = "D3strukt0r"
}
import {
  to = digitalocean_project.myproject
  id = "608255c8-7f7f-407d-bf53-ef749ce89c14"
}
resource "digitalocean_project" "myproject" {
  name        = "Project D3strukt0r"
  description = "All my projects"
  purpose     = "Web Application"
  environment = "Production"
  is_default  = true
  resources = [
    digitalocean_droplet.main.urn,
    digitalocean_volume.main.urn,
  ]
}
import {
  to = digitalocean_droplet.main
  id = "375424082"
}
resource "digitalocean_droplet" "main" {
  image      = "ubuntu-22-04-x64"
  name       = "prod-de"
  region     = "fra1"
  size       = "s-2vcpu-4gb"
  backups    = true
  ipv6       = true
  monitoring = true
  volume_ids = [digitalocean_volume.main.id]
  vpc_uuid   = digitalocean_vpc.main.id

  lifecycle {
    prevent_destroy = true
  }

  #ssh_keys = [
  #  data.digitalocean_ssh_key.d3strukt0r.id
  #]

  #connection {
  #  host        = self.ipv4_address
  #  user        = "root"
  #  type        = "ssh"
  #  private_key = file(var.pvt_key)
  #  timeout     = "2m"
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
import {
  to = digitalocean_volume.main
  id = "b28e1427-6da5-11ee-b7ea-0a58ac14d86d"
}
resource "digitalocean_volume" "main" {
  region = "fra1"
  name   = "volume-fra1-01"
  size   = 100
  #initial_filesystem_type = "ext4"
  #description = "an example volume"

  lifecycle {
    prevent_destroy = true
  }
}
import {
  to = digitalocean_firewall.email
  id = "3954180e-0234-459f-9b4d-68bedf537ca4"
}
resource "digitalocean_firewall" "email" {
  name        = "Email"
  droplet_ids = [digitalocean_droplet.main.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "110"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "143"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "25"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "465"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "587"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "993"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "995"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
import {
  to = digitalocean_firewall.ssh
  id = "2f8c32b2-b051-4517-9775-c1f12fbe1da0"
}
resource "digitalocean_firewall" "ssh" {
  name        = "SSH"
  droplet_ids = [digitalocean_droplet.main.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}
import {
  to = digitalocean_firewall.web
  id = "566a8788-74ea-48fd-8ab8-3cb80e999e41"
}
resource "digitalocean_firewall" "web" {
  name        = "Web"
  droplet_ids = [digitalocean_droplet.main.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
import {
  to = digitalocean_vpc.main
  id = "699e0b9a-7589-41ec-8420-03a4c1f65330"
}
resource "digitalocean_vpc" "main" {
  name     = "default-fra1"
  region   = "fra1"
  ip_range = "10.114.0.0/20"
}
import {
  to = digitalocean_monitor_alert.storage_alert
  id = "bb96aa22-1e9b-4911-b2a8-c8cb0d02b91c"
}
import {
  to = digitalocean_monitor_alert.memory_alert
  id = "9271a11b-3b1a-4b6b-9b4d-f3c804e0d3c6"
}
resource "digitalocean_monitor_alert" "storage_alert" {
  alerts {
    email = [var.do_monitoring_email]
    slack {
      channel = "#digitalocean-alerts"
      url     = var.do_monitoring_slack_webhook
    }
  }
  window  = "5m"
  type    = "v1/insights/droplet/disk_utilization_percent"
  compare = "GreaterThan"
  value   = 80
  enabled = true
  #entities = [digitalocean_droplet.main.id] # all droplets
  description = "Disk Utilization Percent is running high"
}
resource "digitalocean_monitor_alert" "memory_alert" {
  alerts {
    email = [var.do_monitoring_email]
    slack {
      channel = "#digitalocean-alerts"
      url     = var.do_monitoring_slack_webhook
    }
  }
  window  = "5m"
  type    = "v1/insights/droplet/memory_utilization_percent"
  compare = "GreaterThan"
  value   = 90
  enabled = true
  #entities = [digitalocean_droplet.main.id] # all droplets
  description = "Memory Utilization Percent is running high"
}
import {
  to = digitalocean_uptime_check.ping
  id = "68300e8f-39a4-4ea8-89a7-baa1ee3b5ef5"
}
resource "digitalocean_uptime_check" "ping" {
  name    = "Check Ping Container"
  target  = "https://ping.d3strukt0r.dev/"
  regions = ["eu_west", "se_asia", "us_east", "us_west"]
}

output "droplet_ip_addresses" {
  value = digitalocean_droplet.main.ipv4_address
}

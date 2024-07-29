# https://dash.cloudflare.com/profile/api-tokens
# Create Custom Token with "Zone.DNS:Edit" permissions
variable "cloudflare_arepazo_api_token" {
  type        = string
  description = "Cloudflare API token"
  sensitive   = true
  validation {
    condition     = can(regex("^[a-zA-Z0-9_]{40}$", var.cloudflare_arepazo_api_token))
    error_message = "The cloudflare_api_token must be a valid Cloudflare API token."
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_arepazo_api_token
  alias     = "arepazo"
}

locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_arepazo_ch = "643779bc80b781ad8246192ed73cc559"
}

# We can't just target another's account zone through CNAME
# will cause: Error 1014: CNAME Cross-User Banned
import {
  to = cloudflare_record.arepazo-ch-root-v4
  id = "${local.cloudflare_zone_id_arepazo_ch}/f3ea5a3e7bf6e59a91b148c6249417c2"
}
resource "cloudflare_record" "arepazo-ch-root-v4" {
  provider = cloudflare.arepazo
  zone_id  = local.cloudflare_zone_id_arepazo_ch
  name     = "arepazo.ch"
  value    = digitalocean_droplet.main.ipv4_address
  type     = "A"
  proxied  = true
}

import {
  to = cloudflare_record.arepazo-ch-root-v6
  id = "${local.cloudflare_zone_id_arepazo_ch}/3ef6721f6528a3989a333edfb5c046ad"
}
resource "cloudflare_record" "arepazo-ch-root-v6" {
  provider = cloudflare.arepazo
  zone_id  = local.cloudflare_zone_id_arepazo_ch
  name     = "arepazo.ch"
  value    = digitalocean_droplet.main.ipv6_address
  type     = "AAAA"
  proxied  = true
}

import {
  to = cloudflare_record.arepazo-ch-www
  id = "${local.cloudflare_zone_id_arepazo_ch}/0ff34c24c86b7afbcd0554804b9bf8fb"
}
resource "cloudflare_record" "arepazo-ch-www" {
  provider = cloudflare.arepazo
  zone_id  = local.cloudflare_zone_id_arepazo_ch
  name     = "www"
  value    = cloudflare_record.arepazo-ch-root-v4.hostname
  type     = "CNAME"
  proxied  = true
}

import {
  to = cloudflare_record.arepazo-ch-domainconnect
  id = "${local.cloudflare_zone_id_arepazo_ch}/f028c33513af451bd4c93da41e449399"
}
resource "cloudflare_record" "arepazo-ch-domainconnect" {
  provider = cloudflare.arepazo
  zone_id  = local.cloudflare_zone_id_arepazo_ch
  name     = "_domainconnect"
  value    = "_domainconnect.gd.domaincontrol.com"
  type     = "CNAME"
}

import {
  to = cloudflare_record.arepazo-ch-google-verify
  id = "${local.cloudflare_zone_id_arepazo_ch}/4971a2440c61647800b03da149b118f7"
}
resource "cloudflare_record" "arepazo-ch-google-verify" {
  provider = cloudflare.arepazo
  zone_id  = local.cloudflare_zone_id_arepazo_ch
  name     = "arepazo.ch"
  value    = "google-site-verification=AxYYpTxn4z0tGGYFn2YQPqaLi-x5j4GrxzjUf6kI1o0"
  type     = "TXT"
}

import {
  to = cloudflare_record.arepazo-ch-microsoft-verify
  id = "${local.cloudflare_zone_id_arepazo_ch}/c14919d83981eaa496c3de5827f9d96a"
}
resource "cloudflare_record" "arepazo-ch-microsoft-verify" {
  provider = cloudflare.arepazo
  zone_id  = local.cloudflare_zone_id_arepazo_ch
  name     = "arepazo.ch"
  value    = "v=verifydomain MS=5017473"
  type     = "TXT"
}

import {
  to = cloudflare_record.arepazo-ch-autodiscover
  id = "${local.cloudflare_zone_id_arepazo_ch}/40ce380b0bf35974ef22232ab537ea1a"
}
resource "cloudflare_record" "arepazo-ch-autodiscover" {
  provider = cloudflare.arepazo
  zone_id  = local.cloudflare_zone_id_arepazo_ch
  name     = "autodiscover"
  value    = "autodiscover.outlook.com"
  type     = "CNAME"
}

import {
  to = cloudflare_record.arepazo-ch-mx
  id = "${local.cloudflare_zone_id_arepazo_ch}/f120c50817a19802921ae9b494537b2d"
}
resource "cloudflare_record" "arepazo-ch-mx" {
  provider = cloudflare.arepazo
  zone_id  = local.cloudflare_zone_id_arepazo_ch
  name     = "arepazo.ch"
  value    = "arepazo-ch.mail.protection.outlook.com"
  type     = "MX"
}

import {
  to = cloudflare_record.arepazo-ch-spf
  id = "${local.cloudflare_zone_id_arepazo_ch}/7c2b467d33024c42470896051696438b"
}
resource "cloudflare_record" "arepazo-ch-spf" {
  provider = cloudflare.arepazo
  zone_id  = local.cloudflare_zone_id_arepazo_ch
  name     = "arepazo.ch"
  value    = "v=spf1 include:spf.protection.outlook.com -all"
  type     = "TXT"
}

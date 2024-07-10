
locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_d3strukt0r_dev = "1a6f0bb01dc074c1a03af0f173aef29f"
}

import {
  to = cloudflare_record.d3strukt0r-dev-root-v4
  id = "${local.cloudflare_zone_id_d3strukt0r_dev}/e84c23510803e917500c8b9225a1966f"
}
resource "cloudflare_record" "d3strukt0r-dev-root-v4" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_dev
  name    = "prod"
  value   = digitalocean_droplet.main.ipv4_address
  type    = "A"
  proxied = true
}

import {
  to = cloudflare_record.d3strukt0r-dev-root-v6
  id = "${local.cloudflare_zone_id_d3strukt0r_dev}/4f913513aa7f91ae977bf6dd17efa65a"
}
resource "cloudflare_record" "d3strukt0r-dev-root-v6" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_dev
  name    = "prod"
  value   = digitalocean_droplet.main.ipv6_address
  type    = "AAAA"
  proxied = true
}

import {
  to = cloudflare_record.d3strukt0r-dev-root
  id = "${local.cloudflare_zone_id_d3strukt0r_dev}/ed3c835644b82da1d06bce861fa085bd"
}
resource "cloudflare_record" "d3strukt0r-dev-root" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_dev
  name    = "d3strukt0r.dev"
  value   = cloudflare_record.d3strukt0r-dev-root-v6.hostname
  type    = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.d3strukt0r-dev-wildcard
  id = "${local.cloudflare_zone_id_d3strukt0r_dev}/f459f20c6afc3cba8145ec3e6ab98f1a"
}
resource "cloudflare_record" "d3strukt0r-dev-wildcard" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_dev
  name    = "*"
  value   = cloudflare_record.d3strukt0r-dev-root.hostname
  type    = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.d3strukt0r-dev-ssh
  id = "${local.cloudflare_zone_id_d3strukt0r_dev}/d9bf576127a07f63cfa757c0bc370fa9"
}
resource "cloudflare_record" "d3strukt0r-dev-ssh" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_dev
  name    = "ssh"
  value   = cloudflare_record.d3strukt0r-dev-root.hostname
  type    = "CNAME"
  comment = "SSH for Gitea"
}

import {
  to = cloudflare_record.d3strukt0r-dev-portainer-verify
  id = "${local.cloudflare_zone_id_d3strukt0r_dev}/1a87e754e562e545d7f3014a642ddcf0"
}
resource "cloudflare_record" "d3strukt0r-dev-portainer-verify" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_dev
  name    = "_acme-challenge.portainer"
  value   = "cA-vwoFtEbGds71F-aUfCqj2gAJydjMb_LvbeSe3lU4"
  type    = "TXT"
}

import {
  to = cloudflare_record.d3strukt0r-dev-openai-verify
  id = "${local.cloudflare_zone_id_d3strukt0r_dev}/f528a203106138c8cd27a0ceef44fe94"
}
resource "cloudflare_record" "d3strukt0r-dev-openai-verify" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_dev
  name    = "d3strukt0r.dev"
  value   = "openai-domain-verification=dv-iGnk42gpu7REPIIMHXN9H5xz"
  type    = "TXT"
  comment = "OpenAI/ChatGPT Verify"
}

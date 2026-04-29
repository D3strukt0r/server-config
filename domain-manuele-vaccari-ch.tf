
locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_manuele_vaccari_ch = "cbeaf02654d2fa5b4978572f4d4595d0"
}

import {
  to = namecheap_domain_records.manuele-vaccari-ch
  id = "manuele-vaccari.ch"
}
resource "namecheap_domain_records" "manuele-vaccari-ch" {
  domain = "manuele-vaccari.ch"
  nameservers = [
    "brenda.ns.cloudflare.com",
    "wesley.ns.cloudflare.com",
  ]
}

import {
  to = cloudflare_record.manuele-vaccari-ch-root
  id = "${local.cloudflare_zone_id_manuele_vaccari_ch}/13c3b0833eb3bb0edad9a25341c102ff"
}
resource "cloudflare_record" "manuele-vaccari-ch-root" {
  zone_id = local.cloudflare_zone_id_manuele_vaccari_ch
  name    = "manuele-vaccari.ch"
  value   = cloudflare_record.d3strukt0r-dev-root-v6.hostname
  type    = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.manuele-vaccari-ch-wildcard
  id = "${local.cloudflare_zone_id_manuele_vaccari_ch}/88d146360e96917f6c4d6cfcb0855253"
}
resource "cloudflare_record" "manuele-vaccari-ch-wildcard" {
  zone_id = local.cloudflare_zone_id_manuele_vaccari_ch
  name    = "*"
  value   = cloudflare_record.manuele-vaccari-ch-root.hostname
  type    = "CNAME"
  proxied = true
}

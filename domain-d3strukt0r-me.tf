
locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_d3strukt0r_me = "572bdbbd687053ca652d80a0beb8f611"
}

#import {
#  to = namecheap_domain_records.d3strukt0r-me
#  id = "d3strukt0r.me"
#}
#resource "namecheap_domain_records" "d3strukt0r-me" {
#  domain = "d3strukt0r.me"
#  nameservers = [
#    "brenda.ns.cloudflare.com",
#    "wesley.ns.cloudflare.com",
#  ]
#}

import {
  to = cloudflare_record.d3strukt0r-me-wildcard
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/77b1c9dffeabfeb7d9e2d856b280a388"
}
resource "cloudflare_record" "d3strukt0r-me-wildcard" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "*"
  value = "d3strukt0r.me"
  type = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.d3strukt0r-me-root
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/4afb066a0e06370d47b46f46de296493"
}
resource "cloudflare_record" "d3strukt0r-me-root" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "d3strukt0r.me"
  value = "prod.d3strukt0r.dev"
  type = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.d3strukt0r-me-mx1
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/a43020dfe2ab49a8906d8d17d90eeb42"
}
resource "cloudflare_record" "d3strukt0r-me-mx1" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "d3strukt0r.me"
  value = "mail.protonmail.ch"
  type = "MX"
  comment = "ProtonMail"
  priority = 10
}

import {
  to = cloudflare_record.d3strukt0r-me-mx2
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/c543fe35a64451bd09f3eafc9f6ddc8d"
}
resource "cloudflare_record" "d3strukt0r-me-mx2" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "d3strukt0r.me"
  value = "mailsec.protonmail.ch"
  type = "MX"
  comment = "ProtonMail"
  priority = 20
}

import {
  to = cloudflare_record.d3strukt0r-me-dkim
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/f25c01f13ece2c0f1d9091eb4086250d"
}
resource "cloudflare_record" "d3strukt0r-me-dkim" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "protonmail._domainkey"
  value = "protonmail.domainkey.dnkpp4rjxgne6fnd22kwhwduuptqsey7jz7hioquggk5hr4ocdnza.domains.proton.ch"
  type = "CNAME"
  comment = "ProtonMail (Proxy not supported!)"
}

import {
  to = cloudflare_record.d3strukt0r-me-dkim2
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/b5e49eafe081770fe6833c220714fab1"
}
resource "cloudflare_record" "d3strukt0r-me-dkim2" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "protonmail2._domainkey"
  value = "protonmail2.domainkey.dnkpp4rjxgne6fnd22kwhwduuptqsey7jz7hioquggk5hr4ocdnza.domains.proton.ch"
  type = "CNAME"
  comment = "ProtonMail (Proxy not supported!)"
}

import {
  to = cloudflare_record.d3strukt0r-me-dkim3
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/ce74aa88619f2a97380b2cbf6c0f6f30"
}
resource "cloudflare_record" "d3strukt0r-me-dkim3" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "protonmail3._domainkey"
  value = "protonmail3.domainkey.dnkpp4rjxgne6fnd22kwhwduuptqsey7jz7hioquggk5hr4ocdnza.domains.proton.ch"
  type = "CNAME"
  comment = "ProtonMail (Proxy not supported!)"
}

import {
  to = cloudflare_record.d3strukt0r-me-spf
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/52ade00089dba7237cdf6efb13aa6d88"
}
resource "cloudflare_record" "d3strukt0r-me-spf" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "d3strukt0r.me"
  value = "v=spf1 include:_spf.protonmail.ch mx ~all"
  type = "TXT"
  comment = "ProtonMail SPF"
}

import {
  to = cloudflare_record.d3strukt0r-me-dmarc
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/b2babf2f4dd4c73e91ac5f4f3511c7b7"
}
resource "cloudflare_record" "d3strukt0r-me-dmarc" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "_dmarc"
  value = "v=DMARC1; p=none"
  type = "TXT"
  comment = "ProtonMail DMARC"
}

import {
  to = cloudflare_record.d3strukt0r-me-protonmail-verify
  id = "${local.cloudflare_zone_id_d3strukt0r_me}/2123db14983e8c6c7db098816493cc80"
}
resource "cloudflare_record" "d3strukt0r-me-protonmail-verify" {
  zone_id = local.cloudflare_zone_id_d3strukt0r_me
  name = "d3strukt0r.me"
  value = "protonmail-verification=5a33bc1e9b0ec499fa297b4f067069d0da2fc0d1"
  type = "TXT"
  comment = "ProtonMail Verify"
}

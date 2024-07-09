
locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_d3st_org = "fbd415128cf6970d1f88ec27bf0898c7"
}

import {
  to = cloudflare_record.d3st-org-wildcard
  id = "${local.cloudflare_zone_id_d3st_org}/04e6736349a6d98aaf7d9a9d030a6645"
}
resource "cloudflare_record" "d3st-org-wildcard" {
  zone_id = local.cloudflare_zone_id_d3st_org
  name    = "*"
  value   = "d3st.org"
  type    = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.d3st-org-root
  id = "${local.cloudflare_zone_id_d3st_org}/29bf91d15d98ff31644ee44cca629115"
}
resource "cloudflare_record" "d3st-org-root" {
  zone_id = local.cloudflare_zone_id_d3st_org
  name    = "d3st.org"
  value   = "prod.d3strukt0r.dev"
  type    = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.d3st-org-mx1
  id = "${local.cloudflare_zone_id_d3st_org}/94c937a7e1542b2c2b864a2e48dfcd9c"
}
resource "cloudflare_record" "d3st-org-mx1" {
  zone_id  = local.cloudflare_zone_id_d3st_org
  name     = "d3st.org"
  value    = "mail.anonaddy.me"
  type     = "MX"
  comment  = "AnonAddy"
  priority = 10
}

import {
  to = cloudflare_record.d3st-org-mx2
  id = "${local.cloudflare_zone_id_d3st_org}/9912c2a69a19a25985438441b7a6e910"
}
resource "cloudflare_record" "d3st-org-mx2" {
  zone_id  = local.cloudflare_zone_id_d3st_org
  name     = "d3st.org"
  value    = "mail2.anonaddy.me"
  type     = "MX"
  comment  = "AnonAddy"
  priority = 20
}

import {
  to = cloudflare_record.d3st-org-dkim
  id = "${local.cloudflare_zone_id_d3st_org}/2883b61d8f06c15e3c027c39f740d246"
}
resource "cloudflare_record" "d3st-org-dkim" {
  zone_id = local.cloudflare_zone_id_d3st_org
  name    = "dk1._domainkey"
  value   = "dk1._domainkey.anonaddy.me"
  type    = "CNAME"
  comment = "AnonAddy (Proxy not supported!)"
}

import {
  to = cloudflare_record.d3st-org-dkim2
  id = "${local.cloudflare_zone_id_d3st_org}/c43413c6741f0a60f3bc1e7f3f77592f"
}
resource "cloudflare_record" "d3st-org-dkim2" {
  zone_id = local.cloudflare_zone_id_d3st_org
  name    = "dk2._domainkey"
  value   = "dk2._domainkey.anonaddy.me"
  type    = "CNAME"
  comment = "AnonAddy (Proxy not supported!)"
}

import {
  to = cloudflare_record.d3st-org-spf
  id = "${local.cloudflare_zone_id_d3st_org}/2acb350ea42d60f1978b22705e7dbc73"
}
resource "cloudflare_record" "d3st-org-spf" {
  zone_id = local.cloudflare_zone_id_d3st_org
  name    = "d3st.org"
  value   = "v=spf1 include:spf.anonaddy.me -all"
  type    = "TXT"
  comment = "AnonAddy SPF"
}

import {
  to = cloudflare_record.d3st-org-dmarc
  id = "${local.cloudflare_zone_id_d3st_org}/4de66d105404e28ad5046be29a2a17dc"
}
resource "cloudflare_record" "d3st-org-dmarc" {
  zone_id = local.cloudflare_zone_id_d3st_org
  name    = "_dmarc"
  value   = "v=DMARC1; p=quarantine; adkim=s"
  type    = "TXT"
  comment = "AnonAddy DMARC"
}

import {
  to = cloudflare_record.d3st-org-anonaddy-verify
  id = "${local.cloudflare_zone_id_d3st_org}/d994b1474f87a3606d41e067042526b8"
}
resource "cloudflare_record" "d3st-org-anonaddy-verify" {
  zone_id = local.cloudflare_zone_id_d3st_org
  name    = "d3st.org"
  value   = "aa-verify=2ccd78c27a71efbd432a4a83f2e9ec31a0b3d526"
  type    = "TXT"
  comment = "AnonAddy Verify"
}

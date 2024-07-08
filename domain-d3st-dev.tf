
locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_d3st_dev = "314dcef02e6e2ee57f31fe56cd0dcdb2"
}

import {
  to = cloudflare_record.d3st-dev-wildcard
  id = "${local.cloudflare_zone_id_d3st_dev}/f1072fc500596a01166b10d7e30a7bd3"
}
resource "cloudflare_record" "d3st-dev-wildcard" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "*"
  value = "d3st.dev"
  type = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.d3st-dev-root
  id = "${local.cloudflare_zone_id_d3st_dev}/2870a524a43a365a380ae52e3c9246f5"
}
resource "cloudflare_record" "d3st-dev-root" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "d3st.dev"
  value = "prod.d3strukt0r.dev"
  type = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.d3st-dev-dkim
  id = "${local.cloudflare_zone_id_d3st_dev}/becdd07bd6410d812fbabb710eace7f3"
}
resource "cloudflare_record" "d3st-dev-dkim" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "dk1._domainkey"
  value = "dk1._domainkey.anonaddy.me"
  type = "CNAME"
  proxied = false
  comment = "AnonAddy (Proxy not supported!)"
}

import {
  to = cloudflare_record.d3st-dev-dkim2
  id = "${local.cloudflare_zone_id_d3st_dev}/9474c644bfe79407b7c68642ed0d109e"
}
resource "cloudflare_record" "d3st-dev-dkim2" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "dk2._domainkey"
  value = "dk2._domainkey.anonaddy.me"
  type = "CNAME"
  proxied = false
  comment = "AnonAddy (Proxy not supported!)"
}

import {
  to = cloudflare_record.d3st-dev-mx2
  id = "${local.cloudflare_zone_id_d3st_dev}/8a2a3d6ef3e478af5af458fcbc54a8c4"
}
resource "cloudflare_record" "d3st-dev-mx2" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "d3st.dev"
  value = "mail2.anonaddy.me"
  type = "MX"
  comment = "AnonAddy"
  priority = 20
}

import {
  to = cloudflare_record.d3st-dev-mx1
  id = "${local.cloudflare_zone_id_d3st_dev}/06a2ba8b1b0b68a32b14999e670d7d21"
}
resource "cloudflare_record" "d3st-dev-mx1" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "d3st.dev"
  value = "mail.anonaddy.me"
  type = "MX"
  comment = "AnonAddy"
  priority = 10
}

import {
  to = cloudflare_record.d3st-dev-box-verify
  id = "${local.cloudflare_zone_id_d3st_dev}/e361a2a1d4f244fc129d582eb66d0480"
}
resource "cloudflare_record" "d3st-dev-box-verify" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "d3st.dev"
  value = "box-domain-verification=3470b4078aa49daffbd25ad6dfa6088cf90b2740804c2b514915b619a848c1b0"
  type = "TXT"
  comment = "box.com Verify"
}

import {
  to = cloudflare_record.d3st-dev-spf
  id = "${local.cloudflare_zone_id_d3st_dev}/56b81e8d1c9cd90dcd49b5e4a85bf198"
}
resource "cloudflare_record" "d3st-dev-spf" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "d3st.dev"
  value = "v=spf1 include:spf.anonaddy.me -all"
  type = "TXT"
  comment = "AnonAddy SPF"
}

import {
  to = cloudflare_record.d3st-dev-anonaddy-verify
  id = "${local.cloudflare_zone_id_d3st_dev}/9ba77f4c92b60be3b2339c2b3bead106"
}
resource "cloudflare_record" "d3st-dev-anonaddy-verify" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "d3st.dev"
  value = "aa-verify=87b4e4ca1e1631bbd7c005871f9af76c91ac4c17"
  type = "TXT"
  comment = "AnonAddy Verify"
}

import {
  to = cloudflare_record.d3st-dev-dmarc
  id = "${local.cloudflare_zone_id_d3st_dev}/20987934db6bece1be6ab30e683a0a0d"
}
resource "cloudflare_record" "d3st-dev-dmarc" {
  zone_id = local.cloudflare_zone_id_d3st_dev
  name = "_dmarc"
  value = "v=DMARC1; p=quarantine; adkim=s"
  type = "TXT"
  comment = "AnonAddy DMARC"
}

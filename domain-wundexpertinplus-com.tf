
locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_wundexpertinplus_com = "2889e840f9c25c8c2f0283940d549746"
}

import {
  to = cloudflare_record.wundexpertinplus-com-root
  id = "${local.cloudflare_zone_id_wundexpertinplus_com}/ce03b5137ad7759cae03c19a6ac951a2"
}
resource "cloudflare_record" "wundexpertinplus-com-root" {
  zone_id = local.cloudflare_zone_id_wundexpertinplus_com
  name    = "wundexpertinplus.com"
  value   = "prod.d3strukt0r.dev"
  type    = "CNAME"
  proxied = true
  comment = "Alternative (Cyon): s096.cyon.net / prod.d3strukt0r.dev"
}

import {
  to = cloudflare_record.wundexpertinplus-com-www
  id = "${local.cloudflare_zone_id_wundexpertinplus_com}/d6575f417340d4c7e055a0682ac2581b"
}
resource "cloudflare_record" "wundexpertinplus-com-www" {
  zone_id = local.cloudflare_zone_id_wundexpertinplus_com
  name    = "www"
  value   = "wundexpertinplus.com"
  type    = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.wundexpertinplus-com-maildiscovery
  id = "${local.cloudflare_zone_id_wundexpertinplus_com}/2b288df2685ff6d3b050bb49017b0861"
}
resource "cloudflare_record" "wundexpertinplus-com-maildiscovery" {
  zone_id = local.cloudflare_zone_id_wundexpertinplus_com
  name    = "autoconfig"
  value   = "maildiscovery.cyon.ch"
  type    = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.wundexpertinplus-com-mail
  id = "${local.cloudflare_zone_id_wundexpertinplus_com}/5c4ea7b4b606c6f3fa52c7e637cd3aed"
}
resource "cloudflare_record" "wundexpertinplus-com-mail" {
  zone_id = local.cloudflare_zone_id_wundexpertinplus_com
  name    = "mail"
  value   = "wundexpertinplus.com"
  type    = "CNAME"
}

import {
  to = cloudflare_record.wundexpertinplus-com-mx
  id = "${local.cloudflare_zone_id_wundexpertinplus_com}/2183365185a25526f36218741e2e10ff"
}
resource "cloudflare_record" "wundexpertinplus-com-mx" {
  zone_id  = local.cloudflare_zone_id_wundexpertinplus_com
  name     = "wundexpertinplus.com"
  value    = "mail.wundexpertinplus.com"
  type     = "MX"
  comment  = "Cyon"
  priority = 10
}

import {
  to = cloudflare_record.wundexpertinplus-com-autodiscover
  id = "${local.cloudflare_zone_id_wundexpertinplus_com}/1728c1b0f584b1a0c12fa623d1d3580b"
}
resource "cloudflare_record" "wundexpertinplus-com-autodiscover" {
  zone_id = local.cloudflare_zone_id_wundexpertinplus_com
  name    = "_autodiscover._tcp"
  type    = "SRV"
  data {
    service  = "_autodiscover"
    proto    = "_tcp"
    name     = "wundexpertinplus.com"
    priority = 0
    weight   = 0
    port     = 443
    target   = "maildiscovery.cyon.ch"
  }
}

import {
  to = cloudflare_record.wundexpertinplus-com-dkim
  id = "${local.cloudflare_zone_id_wundexpertinplus_com}/9904e51c68a73196c824d1a0d211a5a4"
}
resource "cloudflare_record" "wundexpertinplus-com-dkim" {
  zone_id = local.cloudflare_zone_id_wundexpertinplus_com
  name    = "default._domainkey"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA08ULCdV3L1iSec5bdNLUikPWPyo0AQejFiZgEL6c6v7TgBhDhue5bGcWGEcfwRgVgvyrpYM/nmuBz0WhRvoQ1tbUZcbfHApi3m8wu79ivlI9xM2ar5C3NrqoIs9AvJaQgwjYFkm0mwL4CZqD+TwfAeL7uFSWv3QBZIDK0NLFS5egK4/Rojfytex+YxEhLKnRRcGpCzWOaT7MB7JwKu6gVYaKMV0ThePOYRpeqAhFh9EW8CbyeW+mx7YMY4cn7M+uTwVBbL6bnIdrTUizkdjTKlhk9LM4BIsQWoDRal7kpQar6wn0E18Xud4Fg2VOmFgq9wA7UOLH5RP6y9MvbWbWmQIDAQAB;"
  type    = "TXT"
  comment = "Cyon (Proxy not supported!)"
}

import {
  to = cloudflare_record.wundexpertinplus-com-spf
  id = "${local.cloudflare_zone_id_wundexpertinplus_com}/4f791135e60a45f91e280acc999d8cb4"
}
resource "cloudflare_record" "wundexpertinplus-com-spf" {
  zone_id = local.cloudflare_zone_id_wundexpertinplus_com
  name    = "wundexpertinplus.com"
  value   = "v=spf1 include:spf.protection.cyon.net -all"
  type    = "TXT"
  comment = "Cyon SPF"
}

import {
  to = cloudflare_record.wundexpertinplus-com-dmarc
  id = "${local.cloudflare_zone_id_wundexpertinplus_com}/8a00716728668d4cddc36b8ed202e828"
}
resource "cloudflare_record" "wundexpertinplus-com-dmarc" {
  zone_id = local.cloudflare_zone_id_wundexpertinplus_com
  name    = "_dmarc"
  value   = "v=DMARC1; p=none; rua=mailto:dmarc@wundexpertinplus.com; ruf=mailto:dmarc@wundexpertinplus.com; adkim=s; aspf=s; fo=1"
  type    = "TXT"
  comment = "Cyon DMARC"
}

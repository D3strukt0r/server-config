
locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_manuele_robine_wedding = "edb52a357e98b43f456d8be0a2824979"
}

import {
  to = cloudflare_record.manuele-robine-wedding-root
  id = "${local.cloudflare_zone_id_manuele_robine_wedding}/85341da6bbf85f2470f41e45a54f9f37"
}
resource "cloudflare_record" "manuele-robine-wedding-root" {
  zone_id = local.cloudflare_zone_id_manuele_robine_wedding
  name    = "manuele-robine.wedding"
  value   = cloudflare_record.d3strukt0r-dev-root-v6.hostname
  type    = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.manuele-robine-wedding-wildcard
  id = "${local.cloudflare_zone_id_manuele_robine_wedding}/59c4a690f6660416ad3dae94328d7a8b"
}
resource "cloudflare_record" "manuele-robine-wedding-wildcard" {
  zone_id = local.cloudflare_zone_id_manuele_robine_wedding
  name    = "*"
  value   = cloudflare_record.manuele-robine-wedding-root.hostname
  type    = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.manuele-robine-wedding-brave-verify
  id = "${local.cloudflare_zone_id_manuele_robine_wedding}/bdaa266a66d133bbf35016ffccabc1d8"
}
resource "cloudflare_record" "manuele-robine-wedding-brave-verify" {
  zone_id = local.cloudflare_zone_id_manuele_robine_wedding
  name    = "manuele-robine.wedding"
  value   = "brave-ledger-verification=da7c817db9cea16e297a30e5b95940e4cd4a8f780c8272bbdfc50f73fd426bfd"
  type    = "TXT"
  comment = "Brave Creators"
}

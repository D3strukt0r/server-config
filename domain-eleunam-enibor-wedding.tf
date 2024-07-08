
locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_eleunam_enibor_wedding = "5ae9eebb93c9507e7aeac1900b276e87"
}

import {
  to = cloudflare_record.eleunam-enibor-wedding-wildcard
  id = "${local.cloudflare_zone_id_eleunam_enibor_wedding}/ad6e1b220ce4d987b34826b211e5942e"
}
resource "cloudflare_record" "eleunam-enibor-wedding-wildcard" {
  zone_id = local.cloudflare_zone_id_eleunam_enibor_wedding
  name = "*"
  value = "eleunam-enibor.wedding"
  type = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.eleunam-enibor-wedding-root
  id = "${local.cloudflare_zone_id_eleunam_enibor_wedding}/18acea0f51b6ac90850ed1521b838f48"
}
resource "cloudflare_record" "eleunam-enibor-wedding-root" {
  zone_id = local.cloudflare_zone_id_eleunam_enibor_wedding
  name = "eleunam-enibor.wedding"
  value = "prod.d3strukt0r.dev"
  type = "CNAME"
  proxied = true
}

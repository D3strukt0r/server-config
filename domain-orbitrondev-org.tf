
locals {
  # GET https://api.cloudflare.com/client/v4/zones/<zone_id>/dns_records
  cloudflare_zone_id_orbitrondev_org = "14f5eac86a913b7ca8530dec85d6017c"
}

import {
  to = cloudflare_record.orbitrondev-org-wildcard
  id = "${local.cloudflare_zone_id_orbitrondev_org}/829ead72b11e0bb949f2c325bca69d71"
}
resource "cloudflare_record" "orbitrondev-org-wildcard" {
  zone_id = local.cloudflare_zone_id_orbitrondev_org
  name = "*"
  value = "orbitrondev.org"
  type = "CNAME"
  proxied = true
}

import {
  to = cloudflare_record.orbitrondev-org-root
  id = "${local.cloudflare_zone_id_orbitrondev_org}/154eb6c1851ec64e11ad97fd5fb00c3c"
}
resource "cloudflare_record" "orbitrondev-org-root" {
  zone_id = local.cloudflare_zone_id_orbitrondev_org
  name = "orbitrondev.org"
  value = "prod.d3strukt0r.dev"
  type = "CNAME"
  proxied = true
}

pid_file = "/tmp/pidfile"
disable_mlock = true

vault {
  address = "http://127.0.0.1:8200"
}

auto_auth {
  method "token_file" {
    config = {
      token_file_path = "/vault-agent/token/vault-agent-token"
    }
  }
}

template {
  source      = "/vault-agent/templates/certbot-cloudflare.ini.ctmpl"
  destination = "/vault-agent/rendered/certbot-cloudflare.ini"
  perms       = "0600"
}

template {
  source      = "/vault-agent/templates/pihole-web-password.env.ctmpl"
  destination = "/vault-agent/rendered/pihole-web-password.env"
  perms       = "0600"
}

template {
  source      = "/vault-agent/templates/zigbee2mqtt-secret.yaml.ctmpl"
  destination = "/vault-agent/rendered/zigbee2mqtt-secret.yaml"
  perms       = "0600"
}

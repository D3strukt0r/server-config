# some examples:
# - https://github.com/grimwm/idbm/blob/f526d509c1537e5050cc3f5974689837589367b5/iac/tf/main.tf

# tofu init
terraform {
  #backend "http" {
  #  address        = "https://opentofu-state.d3strukt0r.dev"
  #  lock_address   = "https://opentofu-state.d3strukt0r.dev"
  #  unlock_address = "https://opentofu-state.d3strukt0r.dev"
  #  username       = "admin"
  #  password       = "" # or use TF_HTTP_PASSWORD
  #}

  # Instead of backend use cloud
  #cloud {
  #  organization = "my-org"
  #  hostname     = "tacos.d3strukt0r.dev"

  #  workspaces {
  #    name = "my-infrastructure-prod"
  #  }
  #}

  #encryption {
  #  method "unencrypted" "migrate" {}
  #  key_provider "pbkdf2" "mykey" {
  #    passphrase = "changeme!"
  #  }
  #  key_provider "openbao" "my_bao" {
  #    key_name = "test-key"
  #    token    = "token-from-bao"
  #    address  = "https://openbao.d3strukt0r.dev"
  #  }
  #  method "aes_gcm" "new_method" {
  #    keys = key_provider.pbkdf2.mykey
  #    #keys = key_provider.openbao.my_bao
  #  }
  #  state {
  #    #method = method.unencrypted.migrate
  #    method = method.aes_gcm.new_method
  #    # Run "tofu apply"
  #    # then uncomment:
  #    #enforced = true
  #  }
  #  remote_state_data_sources {
  #    default {
  #      method = method.aes_gcm.new_method
  #    }
  #  }
  #}
}

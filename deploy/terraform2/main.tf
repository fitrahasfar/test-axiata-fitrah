provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone
    credentials = file(var.credentials_file)
}

resource "google_compute_instance" "vm_instance" {
    name = "test-axiata-fitrah"
    machine_type = var.machine_type
    zone = var.zone

    boot_disk {
      initialize_params {
        image = "Ubuntu 22.04 LTS"
      }
    }

    network_interface {
      network = "default"
      access_config {
        nat_ip = null
      }
    }

    metadata = {
      startup-script = <<-EOT
      #!/bin/bash
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://nginx.org/keys/nginx_signing.key -o /etc/apt/keyrings/nginx.asc
      sudo chmod a+r /etc/apt/keyrings/nginx.asc

      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/nginx.asc] http://nginx.org/packages/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") nginx" | \
        sudo tee /etc/apt/sources.list.d/nginx.list > /dev/null
      sudo apt-get update

      sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y
      EOT
    }
}

resource "google_compute_firewall" "default-allow-http" {
    name = "default-allow-http"
    network = "default"

    allow {
      protocol = "tcp"
      ports = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["http-server"]
}
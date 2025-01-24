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

    tags = ["http-server"]

    boot_disk {
      initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2204-lts"
        size = 50
        type = "pd-ssd"
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
      set -e
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc

      # Add the repository to Apt sources:
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update

      # Install Docker
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
      EOT
    }
}
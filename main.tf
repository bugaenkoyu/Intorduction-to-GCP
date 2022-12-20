provider "google" {
  credentials = file("devops-bc-terraform.json")
  project = "devops-bc-371801"
  region = "europe-west3"
  zone = "europe-west3-b"

}

resource "google_compute_instance" "lamp7" {
  name = "lamp-tutorial7"
  machine_type = "e2-micro"

  tags = ["http-server", "https-server"]
  
    boot_disk {
    initialize_params {
        image = "debian-10-buster-v20221206"
        size = 15
    }
  }

  metadata_startup_script =  file("apache.sh")

  network_interface {
    network = google_compute_network.vpc_network7.name
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network7" {
  name = "vpc-firewall7"
}

resource "google_compute_firewall" "ssh" {
  name          = "allow-ssh7"
  network       = google_compute_network.vpc_network7.name
  source_ranges = ["0.0.0.0/0"]
  direction     = "INGRESS"
  priority      = "65534"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "http" {
  name          = "allow-http7"
  network       = google_compute_network.vpc_network7.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
  direction     = "INGRESS"
  priority      = "1000"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "https" {
  name          = "allow-https7"
  network       = google_compute_network.vpc_network7.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
  direction     = "INGRESS"
  priority      = "1000"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

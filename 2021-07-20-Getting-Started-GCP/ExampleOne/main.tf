#Terracom Source > hashicorop/google or (aws,azure) version, newest version is 4.46.0
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.0"
    }
  }
}
#Region multiple regions in Europe : https://cloud.google.com/about/locations#europe 
variable "gcp_region" {
  type        = string
  description = "Region to use for GCP provider"
  default     = "europe-west6"
}
#Description variables
variable "gcp_project" {
  type        = string
  description = "Project to use for this config"
}

provider "google" {
  region  = var.gcp_region
  project = var.gcp_project
}
#Usage :  Using the region that is currently being used for your project
data "google_compute_zones" "available_zones" {}
#Public IP adress will be automatically generated
resource "google_compute_address" "static" {
  name = "apache"
}
#Instance for the apache server
resource "google_compute_instance" "apache" {
  name = "apache"
  zone = data.google_compute_zones.available_zones.names[0]
  tags = ["allow-http"]
#Machine type gives info about the type for 
  machine_type = "e2-micro"
#OS Info
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
#Networking info and script that will run on first startup
  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata_startup_script = file("startup_script.sh")
}
#Firewall settings
resource "google_compute_firewall" "allow_http" {
    name = "allow-http-rule"
    network = "default"
    
    allow {
      ports = ["80"]
      protocol = "tcp"
    }

    target_tags = ["allow-http"]

    priority = 1000
  
}
#Opening the instance so we can connect to it
output "public_ip_address" {
  value = google_compute_address.static.address
}
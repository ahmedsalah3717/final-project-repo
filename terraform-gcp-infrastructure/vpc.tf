resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_compute_network" "vpc_network" {
  project                 = "peerless-aria-377213"
  name                    = "vpc-network"
  auto_create_subnetworks = false
  mtu                     = 1460
  delete_default_routes_on_create = false


}

#######Management Subnet#########
resource "google_compute_subnetwork" "management_subnet" {
    
  name          = "management-subnet"
  ip_cidr_range = "10.1.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
  

}

#######Restricted Subnet#########
resource "google_compute_subnetwork" "restricted_subnet" {
  name                     = "restricted-subnet"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true


  # secondary_ip_range {
  #   range_name    = "kubernetes-pod-range"
  #   ip_cidr_range = "10.48.0.0/14"
  # }

  # secondary_ip_range {
  #   range_name    = "kubernetes-service-range"
  #   ip_cidr_range = "10.52.0.0/20"
  # }

}



# Firewall for VPC 
resource "google_compute_firewall" "management_subnet_firewall" {
 
  name    = "management-subnet-firewall"
  network = google_compute_network.vpc_network.id
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["management-vm"]
  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  
  
}
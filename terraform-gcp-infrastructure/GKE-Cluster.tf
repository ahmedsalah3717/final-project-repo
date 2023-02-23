resource "google_container_cluster" "private_gke_cluster" {
  name                     = "private-gke-cluster"
  location                 = "us-central1"
  
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc_network.id
  subnetwork               = google_compute_subnetwork.restricted_subnet.id

  

  node_locations = [
    "us-central1-b"
  ]



  master_authorized_networks_config {
    cidr_blocks {
        cidr_block = "10.1.0.0/24"
        display_name = "management_subnet"

    }
  }


  
  release_channel {
    channel = "REGULAR"
  }



  ip_allocation_policy {
   
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

}

resource "google_container_node_pool" "cluster_node_pool" {

  name       = "cluster-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.private_gke_cluster.name
  node_count = 1
      node_locations = [
    "us-central1-b"
  ]

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    disk_size_gb = 100
    preemptible  = true
    machine_type = "e2-medium"
    service_account = google_service_account.k8s-sa.email
    oauth_scopes = [
    
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }
}



# kubernetes service account
resource "google_service_account" "k8s-sa" {
  account_id = "k8s-sa"
  display_name = "sa-gke"
}
#calling service acc
resource "google_project_iam_member" "view_access_gke" {
  project = "peerless-aria-377213"
  role = "roles/container.admin"
  member = "serviceAccount:${google_service_account.k8s-sa.email}"
}

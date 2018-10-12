variable project {
  description = "Project ID"
  default = "docker-201818"
}

variable region {
  description = "Region"
  default     = "europe-west4"
}

variable zone {
  description = "Zone"
  default     = "europe-west4-a"
}

variable machine_type {
  description = "Machine type"
  default     = "g1-small"
}

variable disk_size {
  description = "Disk size"
  default     = "20"
}

variable initial_node_count {
  description = "Initial Node Count"
  default     = 2
}

variable gke_version {
  description = "GKE Version"
  default     = "1.8.10-gke.0"
}
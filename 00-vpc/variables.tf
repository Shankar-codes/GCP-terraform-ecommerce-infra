variable project_id {
  description = "GCP project ID"
  type        = string
  default     = "shankar-gcp-practice"
}

variable region {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "public_subnet_cidr" {
  description = "CIDR range for public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR range for private subnet"
  type        = string
  default     = "10.10.2.0/24"
}
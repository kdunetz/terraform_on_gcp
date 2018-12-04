terraform {
 backend "gcs" {
   bucket  = "kevin-terraform-admin"
   prefix  = "terraform/state"
   project = "kevin-terraform-admin"
 }
}

variable "project_name" {}
variable "billing_account" {}
variable "org_id" {}
variable "region" {}

// ESTABLISH GOOGLE PROVIDER with the REGION PASSED IN WITH THE TF_VAR_region parameter
provider "google" {
 region = "${var.region}"
}
// CREATE A FOLDER UNDER THE MAIN 
resource "google_folder" "prod" {
  display_name = "gcp-prod"
  parent       = "organizations/${var.org_id}"
}

// CREATE A RANDOM ID OF PROJECTNAME FOLLOWED BY 4 numbers
resource "random_id" "id" {
 byte_length = 4
 prefix      = "${var.project_name}-"
}

// CREATE A PROJECT
resource "google_project" "project" {
 name            = "${var.project_name}"
 project_id      = "${random_id.id.hex}"
 billing_account = "${var.billing_account}"
 /* org_id          = "${var.org_id}" */
 folder_id          = "${google_folder.prod.id}"
}

// ENABLE APIS to CREATE GCE IMAGES INSIDE THIS PROJECT  
resource "google_project_services" "project" {
 project = "${google_project.project.project_id}"
 services = [
   "compute.googleapis.com"
 ]
}

// PRINT OUT THE PROJECT ID AT THE END
output "project_id" {
 value = "${google_project.project.project_id}"
}

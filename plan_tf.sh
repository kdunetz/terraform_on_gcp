export USER=kevin
export TF_CREDS=~/.config/gcloud/${USER}-terraform-admin.json
export TF_VAR_project_name=${USER}-test-compute
export TF_VAR_region=us-central1
export GOOGLE_APPLICATION_CREDENTIALS=$TF_CREDS

terraform plan

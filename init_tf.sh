# ONLY RUN THIS ONCE TO INITIALIZE THE WHOLE TERRAFORM...then you can run other run_tf.sh
#gcloud organizations list
#gcloud beta billing accounts list
export USER=kevin
export TF_VAR_org_id=
export TF_VAR_billing_account=
export TF_ADMIN=${USER}-terraform-admin
export TF_CREDS=~/.config/gcloud/${USER}-terraform-admin.json


gcloud projects create ${TF_ADMIN} \
  --organization ${TF_VAR_org_id} \
  --set-as-default

gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_billing_account}

gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

# Create the json file referenced above
gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
# KAD added this to enable Cloud SQL Admin APIs
gcloud services enable sqladmin.googleapis.com

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user

### KAD add new permissions to create more stuff here
### run this command to find new roles to add - gcloud beta iam roles list | grep sql
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
     --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
     --role roles/resourcemanager.folderCreator

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
     --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
     --role roles/cloudsql.admin

### KAD end of new stuff block

gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}

cat > backend.tf <<EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_ADMIN}"
   prefix  = "terraform/state"
   project = "${TF_ADMIN}"
 }
}
EOF

gsutil versioning set on gs://${TF_ADMIN}

export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_ADMIN}

export TF_VAR_project_name=${USER}-test-compute
export TF_VAR_region=us-central1

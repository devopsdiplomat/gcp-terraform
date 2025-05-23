# Terraform code to provision in GCP

## Generate service account key and create GitHub secret in GCP
Run the below commands in Google cloud shell
```
PROJECT_ID = "<copy from GCP>"

# set the project in cloud shell. 
gcloud config set project ${PROJECT_ID}

# Create service account
gcloud iam service-accounts create github-wif-id \
--display-name="Service account used by WIF" \
--project="${PROJECT_ID}"

# Assign permissions to service account and allow wif to authenticate and impersonate service account
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:github-wif-id@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/compute.viewer"

gcloud iam service-accounts add-iam-policy-binding "github-wif-id@${PROJECT_ID}.iam.gserviceaccount.com" --project="${PROJECT_ID}" --role="roles/iam.workloadIdentityUser" --member="principalSet://iam.googleapis.com/projects/324931948700/locations/global/workloadIdentityPools/github-wif-pool/attribute.repository/devopsdiplomat/gcp-terraform"

# Setup keyless authentication with GCP using workload-identitiy 
# Create workload identitiy pool
gcloud iam workload-identity-pools create "github-wif-pool" \
  --project="${PROJECT_ID}" \
  --location="global" \
  --display-name="Pool setup for GitHub Actions"

# Create workload-identity-pools provider
gcloud iam workload-identity-pools providers create-oidc githubwif \
    --project="${PROJECT_ID}" \
    --location="global" \
    --workload-identity-pool="github-wif-pool" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="attribute.actor=assertion.actor,google.subject=assertion.sub,attribute.repository=assertion.repository" \
    --attribute-condition="attribute.owner==assertion.repository"

# List the created pool and get its name to use in GitHub Actions
gcloud iam workload-identity-pools providers list --workload-identity-pool="github-pool" --location="global"
gcloud iam workload-identity-pools list --location global --format "get(name)"
```
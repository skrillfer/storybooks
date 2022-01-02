PROJECT_ID=devops-0794-personal
ZONE=us-central1-a

run-local:
	docker-compose up

###
create-tf-backend-bucket:
	gsutil mb -p $(PROJECT_ID) gs://$(PROJECT_ID)-terraform

###
define get-secret
$(shell gcloud secrets versions access latest --secret=$(1) --project=$(PROJECT_ID))
endef

###
ENV=staging
terraform-create-workspace:
	cd terraform && \
	  terraform workspace new $(ENV)

terraform-init:
	cd terraform && \
	  terraform workspace select $(ENV) && \
	  terraform init

TF_ACTION?=plan
terraform-action:
	cd terraform && \
	  terraform workspace select $(ENV) && \
	  terraform $(TF_ACTION) \
	  -var-file="./environments/common.tfvars" \
	  -var-file="./environments/$(ENV)/config.tfvars" \
	  -var="mongodbatlas_private_key=$(call get-secret,atlas_private_key)" \
	  -var="atlas_user_password=$(call get-secret,atlas_user_password_$(ENV))" \
	  -var="cloudflare_api_token=$(call get-secret,cloudflare_api_token)"

### DEPLOYMENT MANUALLY
SSH_STRING = palas@storybooks-vm-$(ENV)

VERSION?=latest
LOCAL_TAG=storybooks-app:$(VERSION)
REMOTE_TAG=gcr.io/$(PROJECT_ID)/$(LOCAL_TAG)
ssh:
	gcloud compute ssh $(SSH_STRING) \
	 --project=$(PROJECT_ID) \
	 --zone=$(ZONE)
ssh-cmd:
	gcloud compute ssh $(SSH_STRING) \
	 --project=$(PROJECT_ID) \
	 --zone=$(ZONE) \
	 --command="$(CMD)"

build:
	docker build -t $(LOCAL_TAG) .

push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)
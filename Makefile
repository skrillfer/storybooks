PROJECT_ID=devops-0794-personal

run-local:
	docker-compose up

###
create-tf-backend-bucket:
	gsutil mb -p $(PROJECT_ID) gs://$(PROJECT_ID)-terraform
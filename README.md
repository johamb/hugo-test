# hugo-test
This is a demonstration on how to build a lightweight static site with [Hugo](https://gohugo.io/) and deploy it to Google Cloud Platform using [Terraform](https://www.terraform.io/).

## Setup

## Deploy
### Step 1: setup infrastructure with terraform
```
cd terraform
terraform init
gcloud auth application-default login
terraform apply
cd ..
```
### Step 2: build and deploy site with hugo
```
cd hugo
hugo -D
hugo deploy
```
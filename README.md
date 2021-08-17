# hugo-test
testing hugo ssg

## Deploy
### Step 1: Setup infrastructure with terraform
```
cd terraform
terraform init
gcloud auth application-default login
terraform apply
cd ..
```
### Step 2: Build and deploy site with hugo
```
cd hugo
hugo -D
hugo deploy
```
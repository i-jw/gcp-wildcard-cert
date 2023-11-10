# gcp-wildcard-cert
## 如何使用
### 设置GCP认证
```shell
gcloud auth application-default login
或者
GOOGLE_CREDENTIALS=service-account-key-xxxx.json
```
### 设置AWS认证
```shell
export AWS_ACCESS_KEY_ID=XXX
export AWS_SECRET_ACCESS_KEY=XXX
```
### 部署，注意替换环境变量中的项目ID和域名
```shell
cd examples
terraform init
terraform apply -var="project_id=PROJECT_ID" -var="domain=example.com" --auto-approve
```
### 销毁资源
```shell
terraform destroy -var="project_id=PROJECT_ID" -var="domain=example.com" --auto-approve
```


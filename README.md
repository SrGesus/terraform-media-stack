
For k3s had to do this in order for traefik ingresses to work.
```bash
firewall-cmd --permanent --add-port=6443/tcp #apiserver
firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services
firewall-cmd --reload
```

# Multi-stage deployment
```bash
terraform init
terraform apply -target=null_resource.bootstrapper
terraform apply -auto-approve
```

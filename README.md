# Terraform Media Stack

## Configuration

You should change the [.auto.tfvars] file to match your desired configuration
```bash
# Path to your kube config
kubeconfig="/etc/rancher/k3s/k3s.yaml"
# Choose a better login than this
username = "user"
password = "123"
# Path to your Libraries folders
movies = "/home/user/Downloads/Movies/Movies"
shows = "/home/user/Downloads/Movies/Shows"
downloads = "/home/user/Downloads"
```

## Setup
First you need to have a kubernetes cluster running, since this is still a single node setup you can easily install for example k3s:
```bash
curl -sfL https://get.k3s.io | sh -
```

For k3s had to do this in order for traefik ingresses to work.
```bash
firewall-cmd --permanent --add-port=6443/tcp #apiserver
firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services
firewall-cmd --reload
```

### Multi-stage deployment
```bash
terraform init
sudo terraform apply -target=null_resource.bootstrapper -auto-approve
sleep 10
sudo terraform apply -auto-approve
```

### Note
Due to limitations imposed by the servarr providers, this is meant to be executed only once for deployment, and then not used for reconfigurations.
If you want to clean everything up try:
```bash
sudo terraform destroy
rm -rf k8s/data
``` 
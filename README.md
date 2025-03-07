# kino

My homeserver's media stack setup in Terraform.

## Setup
First you need to have a kubernetes cluster running, since this is still a single node setup you can easily install for example k3s:
```bash
curl -sfL https://get.k3s.io | sh - 
```

<!-- For k3s had to do this in order for traefik ingresses to work.
```bash
firewall-cmd --permanent --add-port=6443/tcp #apiserver
firewall-cmd --permanent --zone=trusted --add-source=10.42.0.0/16 #pods
firewall-cmd --permanent --zone=trusted --add-source=10.43.0.0/16 #services
firewall-cmd --reload
``` -->

Now you can deploy to the cluster.
```bash
terraform init
terraform apply -auto-approve -target=null_resource.deployment
terraform apply -auto-approve
```

## Variables
Currently the setup is a bit inflexible but that will be improved.

The content is stored in local folders.
```conf
# Path to your kube config
kubeconfig = "~/.kube/config"

# The path where Downloaded content is to be stored.
downloads = "~/Downloads"

applications = {
  radarr = {
    # Path to where the final media content is to be stored. 
    library = "~/Downloads/Movies/Movies"
  }
  sonarr = {
    library = "~/Downloads/Movies/Shows"
  }
  prowlarr = {
    library = "~/Downloads/"
  }
}
```

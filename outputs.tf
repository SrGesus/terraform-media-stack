
resource "local_file" "routes" {
  filename = "routes.json"
  content = jsonencode(module.deployment.routes)
}

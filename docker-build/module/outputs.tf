output "images" {
  description = "Docker image urls generated by the build"
  value       = [
    for tag in local.image_tags : "${local.repository_url}:${tag}"
  ]
}

output "image_name" {
  value = local.image_name
}

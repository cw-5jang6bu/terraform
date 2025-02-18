# resource "kubectl_manifest" "ecr_secret" {
#     yaml_body = <<YAML
#   apiVersion: v1
#   kind: Secret
#   metadata:
#     name: ecr-registry-secret
#     namespace: default
#   data:
#     .dockerconfigjson: "$(aws ecr get-login-password --region ${var.aws_region} | base64)"
#   type: kubernetes.io/dockerconfigjson
#   YAML
#
#   depends_on = [module.eks]
# }

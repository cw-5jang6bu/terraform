# resource "kubectl_manifest" "my_app" {
#   yaml_body = <<YAML
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: my-app
#   namespace: argocd
# spec:
#   destination:
#     namespace: default
#     server: https://kubernetes.default.svc
#   project: default
#   source:
#     repoURL: https://github.com/my-org/my-app-repo.git  # ✅ 애플리케이션 Git 저장소
#     targetRevision: HEAD
#     path: manifests
#   syncPolicy:
#     automated:
#       prune: true
#       selfHeal: true
# YAML
#
#   depends_on = [helm_release.argocd]
# }

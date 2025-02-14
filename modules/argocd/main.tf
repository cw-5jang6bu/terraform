# EKS가 완전히 생성된 후 실행을 보장하는 null_resource
resource "null_resource" "wait_for_eks" {
  depends_on = [var.cluster_id]  # EKS가 완전히 생성된 후 실행
}
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.8.1"

  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  depends_on = [module.eks]  # ✅ EKS 생성 후 ArgoCD 실행
}

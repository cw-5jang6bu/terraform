resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.8.1"

  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"  # ✅ 외부에서 접속 가능하도록 설정
  }

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"  # ✅ HTTPS 인증서 검증 비활성화 (테스트용)
  }

  depends_on = [var.cluster_id]
}




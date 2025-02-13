output "argocd_url" {
  description = "ArgoCD 서버의 외부 접근 주소"
  value       = "http://${helm_release.argocd.name}.elb.amazonaws.com"
}

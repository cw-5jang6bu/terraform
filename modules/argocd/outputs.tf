output "argocd_url" {
  description = "ArgoCD 서버의 외부 접근 주소, ArgoCD의 LoadBalancer URL"
  value       = "http://${helm_release.argocd[0].name}.elb.amazonaws.com"
}

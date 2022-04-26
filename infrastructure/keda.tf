resource "kubernetes_namespace" "keda" {
  metadata {
    name = "keda"
  }
}

resource "helm_release" "keda" {
  name       = "keda"

  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = "2.2.0"
  namespace  = kubernetes_namespace.keda.metadata.0.name

}
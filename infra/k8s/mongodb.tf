resource "helm_release" "mongodb" {
  chart = "bitnami/mongodb"
  name = "mongodb"
  namespace = kubernetes_namespace.db.metadata[0].name
  set {
    name = "architecture"
    value = "replicaset"
  }
  set {
    name = "replicaCount"
    value = "3"
  }
  set {
    name = "auth.rootPassword"
    value = "admin123"
  }
  set {
    name = "auth.replicaSetKey"
    value = "somerandomkey"
  }
  set {
    name = "tolerations[0].key"
    value = "tier"
  }
  set {
    name = "tolerations[0].operator"
    value = "Equal"
  }
  set {
    name = "tolerations[0].value"
    value = "db"
  }
}

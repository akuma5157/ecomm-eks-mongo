resource "kubernetes_namespace" "build" {
  metadata {
    labels = {
      Name = "build"
    }
    name = "build"
  }
}
resource "kubernetes_namespace" "app" {
  metadata {
    labels = {
      Name = "app"
    }
    name = "app"
  }
}
resource "kubernetes_namespace" "db" {
  metadata {
    labels = {
      Name = "db"
    }
    name = "db"
  }
}

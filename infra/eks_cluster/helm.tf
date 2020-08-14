resource "helm_release" "dashboard" {
  name  = "dashboard"
  chart = "stable/kubernetes-dashboard"
  values = [
    file("${path.module}/helm/dashboard-values.yml")
  ]
}

resource "helm_release" "alb_ingress" {
  name = "alb_ingress"
  chart = "incubator/aws-alb-ingress-controller"
  set {
    name = "clusterName"
    value = "${var.name}-EKS"
  }
  set {
    name = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name = "autoDiscoverAwsVpcID"
    value = "true"
  }
}

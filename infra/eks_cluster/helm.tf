//resource "helm_release" "dashboard" {
//  depends_on = [module.eks.cluster_id, helm_release.alb_ingress]
//  name  = "dashboard"
//  chart = "stable/kubernetes-dashboard"
//  values = [
//    file("${path.module}/helm/dashboard-values.yml")
//  ]
//}

resource "helm_release" "alb_ingress" {
  depends_on = [module.eks.cluster_id]
  name = "albingress"
  chart = "incubator/aws-alb-ingress-controller"
  set {
    name = "clusterName"
    value = "${var.name}-EKS"
  }
  set {
    name = "awsVpcID"
    value = var.vpc_id
  }
  set {
    name = "awsRegion"
    value = var.aws_region
  }
  wait = true
}

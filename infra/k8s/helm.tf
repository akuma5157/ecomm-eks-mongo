resource "helm_release" "dashboard" {
  name  = "dashboard"
  chart = "stable/kubernetes-dashboard"
  namespace = "kube-system"
  values = [file("${path.module}/helm-values/values.dashboard.yml")]
  set {
    name = "ingress.hosts[0]"
    value = "dashboard.${var.domain_name}"
  }
}

resource "helm_release" "cluster_autoscaler" {
  chart = "stable/cluster-autoscaler"
  name = "cluster-autoscaler"
  set {
    name = "autoDiscovery.clusterName"
    value = var.eks_cluster_name
  }
}

resource "helm_release" "jenkins" {
  chart = "stable/jenkins"
  name = "jenkins"
  values = [
    file("${path.module}/helm-values/values.jenkins.yml")
  ]
  set {
    name = "ingress.hostName"
    value = "jenkins.${var.domain_name}"
  }
}
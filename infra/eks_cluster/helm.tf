resource "helm_release" "dashboard" {
  depends_on = [module.eks.cluster_id, helm_release.alb_ingress]
  name  = "dashboard"
  chart = "stable/kubernetes-dashboard"
  values = [
    file("${path.module}/helm-values/values.dashboard.yml")
  ]
  set {
    name = "ingress.hosts[0]"
    value = "dashboard.${var.domain_name}"
  }
}

resource "helm_release" "alb_ingress" {
  depends_on = [module.eks.cluster_id]
  name = "alb-ingress"
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

resource "helm_release" "external_dns" {
  chart = "stable/external-dns"
  name = "external-dns"
  values = [
    file("${path.module}/helm-values/values.external-dns.yml")
  ]
  set {
    name = "domainFilters[0]"
    value = var.domain_name
  }
}

resource "helm_release" "merged_ingress" {
  chart = "${path.module}/charts/ingress-merge/helm"
  name = "ingress-merge"
}

resource "kubernetes_config_map" "merged_ingress" {
  metadata {
    name = "merged-ingress"
  }
  data = {
    annotation = <<-EOF
      |
          kubernetes.io/ingress.class: alb
          # required to use ClusterIP
          alb.ingress.kubernetes.io/target-type: ip
          # required to place on public-subnet
          alb.ingress.kubernetes.io/scheme: internet-facing
          # use TLS registered to our domain, ALB will terminate the certificate
          # alb.ingress.kubernetes.io/certificate-arn: ${var.cert_arn}
          # respond to both ports
          # alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
          # redirect to port 80 to port 443
          # alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
      EOF
  }
}
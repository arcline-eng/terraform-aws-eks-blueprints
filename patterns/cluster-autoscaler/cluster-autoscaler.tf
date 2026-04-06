################################################################################
# Cluster Autoscaler IAM Role (IRSA)
################################################################################

module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                        = "${local.name}-cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

  tags = local.tags
}

################################################################################
# Cluster Autoscaler Helm Release
################################################################################

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.37.0"
  wait       = false

  values = [
    <<-EOT
    autoDiscovery:
      clusterName: ${module.eks.cluster_name}
    awsRegion: ${local.region}
    rbac:
      serviceAccount:
        create: true
        name: cluster-autoscaler
        annotations:
          eks.amazonaws.com/role-arn: ${module.cluster_autoscaler_irsa.iam_role_arn}
    extraArgs:
      balance-similar-node-groups: true
      skip-nodes-with-system-pods: false
      expander: least-waste
      scale-down-delay-after-add: 5m
      scale-down-unneeded-time: 5m
    EOT
  ]

  depends_on = [module.eks]
}

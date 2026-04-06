# EKS Cluster Autoscaler Pattern

This pattern deploys an EKS cluster with [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) for automatic node scaling based on pod resource requests.

## Components

- EKS cluster v1.30 with managed node groups
- Cluster Autoscaler via Helm with IRSA authentication
- Auto-discovery of node groups via ASG tags
- Least-waste expander strategy for cost optimization

## When to use Cluster Autoscaler vs Karpenter

| Feature | Cluster Autoscaler | Karpenter |
|---------|-------------------|-----------|
| Scaling unit | ASG (node group) | Individual nodes |
| Instance selection | Pre-defined in ASG | Dynamic, best-fit |
| Scale-down speed | 5-10 minutes | 30 seconds |
| Complexity | Lower | Higher |
| Maturity | Production-grade | Production-grade (since v1.0) |

Use Cluster Autoscaler when you want simpler operations and your workloads fit well into a small number of instance types. Use Karpenter when you need faster scaling, diverse instance types, or fine-grained scheduling constraints.

## Deploy

```bash
terraform init
terraform apply
```

Configure kubectl:

```bash
aws eks --region us-west-2 update-kubeconfig --name cluster-autoscaler-ex
```

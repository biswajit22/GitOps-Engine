locals {
  cluster_version = "1.28"
  vpc_id          = "vpc-12345678" # Replace with actual VPC ID
  subnet_ids      = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"] # Replace with actual Subnets
}

# -----------------------------------------------------------------------------
# Hub: Management Cluster (ArgoCD & Core Services)
# -----------------------------------------------------------------------------
module "eks_management" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21"

  cluster_name    = "gitops-management-cluster"
  cluster_version = local.cluster_version

  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    mgmt = {
      min_size     = 2
      max_size     = 5
      desired_size = 3

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "management"
    Role        = "hub"
  }
}

# -----------------------------------------------------------------------------
# Spoke: Dev Workload Cluster
# -----------------------------------------------------------------------------
module "eks_dev" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21"

  cluster_name    = "gitops-workload-dev"
  cluster_version = local.cluster_version

  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    dev_apps = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "dev"
    Role        = "spoke"
  }
}

# -----------------------------------------------------------------------------
# Spoke: Prod Workload Cluster
# -----------------------------------------------------------------------------
module "eks_prod" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21"

  cluster_name    = "gitops-workload-prod"
  cluster_version = local.cluster_version

  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  cluster_endpoint_public_access = false # Private API server for Prod
  
  eks_managed_node_groups = {
    prod_apps = {
      min_size     = 3
      max_size     = 10
      desired_size = 3

      instance_types = ["m5.large"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "prod"
    Role        = "spoke"
  }
}

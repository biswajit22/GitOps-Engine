# Production-Grade GitOps Engine

This repository demonstrates the configuration and deployment of a Hub-and-Spoke Kubernetes architecture utilizing modern GitOps practices, Infrastructure as Code, and Progressive Delivery.

## 🏗️ Architecture Design: Hub-and-Spoke

The architecture features a single **Management Cluster** (the Hub) acting as the central control plane, which orchestrates deployments to multiple **Workload Clusters** (the Spokes) configured for `dev` and `prod` environments.

### Why Hub-and-Spoke?
1. **Security Isolation:** Workload clusters run user-facing applications and are isolated from the GitOps control plane. A compromise in a workload cluster does not grant access to the management toolchain or other environments.
2. **Scalability:** Enables painless scaling of clusters. You deploy ArgoCD once, avoiding the "ArgoCD-per-cluster" overhead, and dynamically add new clusters as application demand grows.
3. **Blast Radius Reduction:** Administrative activities are separated from standard application traffic. Upgrading the management cluster won't affect the uptime of production workloads.

## 🛠️ Technology Stack

- **Infrastructure as Code (IaC):** Modular Terraform (v1.5+) using S3 backend and DynamoDB locking state backend. Provisioned entirely around `terraform-aws-modules/eks/aws`.
- **GitOps:** ArgoCD using the **ApplicationSet** pattern to automatically discover and orchestrate spoke clusters based on secret labeling.
- **Deployments:** Helm charts wrapped with **Argo Rollouts** for Progressive Delivery using a 20% -> 50% -> 100% Canary strategy.
- **Secrets Management:** Integrated with AWS Secrets Manager utilizing the **External Secrets Operator (ESO)** to inject secrets securely into clusters, fulfilling the requirement of zero secrets stored in Git.
- **Continuous Integration:** GitHub Actions triggering on pull requests for infrastructure validation (`tflint`, `checkov`, `terraform plan`) and auto-updating image tags post-merge into the Helm values repo.

## 📁 Repository Structure

* `infrastructure/terraform/`: Terraform configurations for provisioning the Hub and Spoke EKS clusters.
* `gitops/management/`: ArgoCD bootstrap configurations, including the primary ApplicationSet mapping apps to workload clusters.
* `apps/`: The source of truth for applications deployed to workload clusters, demonstrating Helm and Argo Rollouts natively.
* `.github/workflows/`: CI pipeline definitions enforcing security scanning and deploying config changes.

## 🚀 Deployment Strategy (Progressive Delivery)

Traditional deployments typically swap traffic 100% abruptly. Utilizing **Argo Rollouts**, this setup demonstrates a safer Canary strategy:
1. **20% Canary:** Once an image tag updates in Git, a new ReplicaSet spins up taking 20% of traffic.
2. **Analysis/Pause:** The rollout pauses indefinitely, ensuring engineers or automated data metrics can verify the stability.
3. **50% Ramp:** After approval, it scales to 50% traffic for further baking over a specified time.
4. **100% Auto-Promotion:** The system routes fully to the new version if no degraded performance occurs.

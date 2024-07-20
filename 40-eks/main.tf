resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # you can paste the public key directly like this
  #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzDhIVcz1Dk/3wHFVrGj7XmdfYw22Nndsk+jEIZpvV/zcdEmCFekiyJ/EBUvNcdXM3hCmvyjLu4XJQ+/4eaIDglWejs/LFfJnNkClFCL9CzKVk+gTH7G9bBjukuAB7PgoeNQEp8Iu3b7gHdilsGzZ7SaOJI6WH+SRS0blAtboVcOyIbmkRoo8SuFKNwq8+7XKAVT+as+DTiBltkET61B+Ixv5NYU1lnbb2s7X/cn0XN4LQlmmv+ofeX+QGcy2reFy+ARhKMSUWwHjJSbD3QAoKISzkwAKUEr2Q9TEmfQsRxpZCoSEH0mYX682ignyzE/a1XFuPmsMuikVp99sMmRRVNBll8jUjxifX+vTAoGlBNy46+m/v9AIjm0BPMiJmqrmhzqW4YDPkiCuTm1teiopAhJQvhHrY5O2v9gvALWtmuJqRQcmFJB7qUGTYyr+WT3Sk5OPM+NcddEa6NJnOkXoa7M45zizQ0H5PvsPtfiLM8iNDIfLYor9YBXgvK9hVITmj6dz9R4ud/ZUuFQnTPwiV3dkR/QVcm2tx5lew+5z5/nWzGJ25Pj/nYCgj5pDC7QV1a5yEPLbNqdQ3P32iBpiKemNryCv0OhXlcl+lZYQ96xFQUSu1kbjs0UJAEUWmoEcyOpCqmiEbw1Bd4zAXEH1PXXHeVkHC0Ot9EzK3+GK/+w== eks"

  public_key = file("~/.ssh/id_rsa.pub")
  # ~ means windows home directory
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  #cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr
  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.30"
  # it should be false in PROD environments
  cluster_endpoint_public_access = true

  vpc_id                   = local.vpc_id
  subnet_ids               = split(",", local.private_subnet_ids)
  control_plane_subnet_ids = split(",", local.private_subnet_ids)

  create_cluster_security_group = false
  cluster_security_group_id     = local.cluster_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # the user which you used to create cluster will get admin access
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # blue = {
    #   min_size      = 2
    #   max_size      = 10
    #   desired_size  = 2
    #   capacity_type = "SPOT"
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
    #   }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
    #   key_name = aws_key_pair.eks.key_name
    # }
    green = {
      min_size      = 2
      max_size      = 10
      desired_size  = 2
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
      }
      # EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.id_rsa.pub.key_name
    }
  }

  tags = var.common_tags
}
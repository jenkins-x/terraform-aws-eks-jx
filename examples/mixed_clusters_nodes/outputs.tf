output "workers" {
  value       = module.eks-jx.worker_groups_launch_template
  description = "Output of worker groups launch templates"
}

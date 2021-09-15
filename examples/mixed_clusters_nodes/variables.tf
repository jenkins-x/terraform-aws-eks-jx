// -----------------------------
//  Cluster Nodes
// -----------------------------
//
// Mixed cluster nodes (spot and on-demand). Adding few extra-nodes like pipeline and database to decrease cost.
// Cluster Result:
//  application - 2 on-demand and 1 spot nodes, autoscaling - all next nodes will be spot.
//  pipeline    - 0 on-demand and 2 spot nodes, autoscaling - all next nodes will be spot. Adding labels and taints
//  database    - 2 on-demand and 0 spot nodes, autoscaling - all next nodes will be on-demand. Adding labels and taints
//

variable "workers" {
  description = "Define which nodes user need"
  default = {
    workers = {
      application = {
        on_demand_base_capacity = 2
        asg_min_size            = 2
        asg_max_size            = 3
        asg_desired_capacity    = 3
      }
      pipeline = {
        k8s_labels              = "node.kubernetes.io/component=pipelines"
        k8s_taints              = "component=pipelines:NoSchedule"
        on_demand_base_capacity = 0
        asg_min_size            = 1
        asg_max_size            = 5
        asg_desired_capacity    = 2
        tags = [{
          key                 = "component"
          propagate_at_launch = "true"
          value               = "pipelines"
        }]
      }
      database = {
        k8s_labels              = "node.kubernetes.io/component=database"
        k8s_taints              = "component=database:NoSchedule"
        on_demand_base_capacity = 3
        asg_min_size            = 1
        asg_max_size            = 3
        asg_desired_capacity    = 2
        tags = [{
          key                 = "component"
          propagate_at_launch = "true"
          value               = "database"
        }]
      }
    }
  }
}

#  gcloud compute http-health-checks create kubernetes \
#     --description "Kubernetes Health Check" \
#     --host "kubernetes.default.svc.cluster.local" \
#     --request-path "/healthz"
#   gcloud compute target-pools create kubernetes-target-pool \
#     --http-health-check kubernetes
#   gcloud compute target-pools add-instances kubernetes-target-pool \
#    --instances controller-0,controller-1,controller-2
#   gcloud compute forwarding-rules create kubernetes-forwarding-rule \
#     --address ${KUBERNETES_PUBLIC_ADDRESS} \
#     --ports 6443 \
#     --region $(gcloud config get-value compute/region) \
#     --target-pool kubernetes-target-pool
resource "google_compute_target_pool" "khw-hc-target-pool" {
  name = "instance-pool"

  # TODO: fixed set for now, maybe we can make this dynamic some day
  instances = [
    "${var.region_default_zone}/controller-0",
    "${var.region_default_zone}/controller-1",
    "${var.region_default_zone}/controller-2",
  ]

  health_checks = [
    "${google_compute_http_health_check.khw-health-check.name}",
  ]
}

resource "google_compute_http_health_check" "khw-health-check" {
  name         = "kubernetes"
  request_path = "/healthz"
  description  = "The health check for Kubernetes API server"
  host         = "${var.kubernetes-cluster-dns}"
}

resource "google_compute_forwarding_rule" "khw-hc-forward" {
  name       = "kubernetes-forwarding-rule"
  target     = "${google_compute_target_pool.khw-hc-target-pool.self_link}"
  region     = "${var.region}"
  port_range = "6443"
  ip_address = "${google_compute_address.khw-lb-public-ip.self_link}"
}

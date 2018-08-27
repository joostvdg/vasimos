echo "### LOADBALANCER SCRIPT"

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')
echo " # KUBERNETES_PUBLIC_ADDRESS=${KUBERNETES_PUBLIC_ADDRESS}"

######################################
######################################
### Part of terraform configuration
###
#########################
#########################
#
# echo " # create http health check"
# gcloud compute http-health-checks create kubernetes \
#     --description "Kubernetes Health Check" \
#     --host "kubernetes.default.svc.cluster.local" \
#     --request-path "/healthz"

# echo " # open up firewall for http healt check"
# gcloud compute firewall-rules create kubernetes-the-hard-way-allow-health-check \
#     --network kubernetes-the-hard-way \
#     --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
#     --allow tcp

# echo " # create target pool for health check"
# gcloud compute target-pools create kubernetes-target-pool \
#     --http-health-check kubernetes

# echo " # add controllers (0,1,2) to target pool"
# gcloud compute target-pools add-instances kubernetes-target-pool \
#     --instances controller-0,controller-1,controller-2

# echo " # create forwarding rule for API servers"
# gcloud compute forwarding-rules create kubernetes-forwarding-rule \
#     --address ${KUBERNETES_PUBLIC_ADDRESS} \
#     --ports 6443 \
#     --region $(gcloud config get-value compute/region) \
#     --target-pool kubernetes-target-pool
######################################
######################################


echo " # Verify API server can be reached from outside"
# curl --cacert ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
http --cert ca.pem --cert-key ca-key.pem --verify no https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
ENC_FOLDER=../encryption

echo "### ENCRYPTION CONFIG CREATION SCRIPT"
echo " ## Removing encryption file if exists"
rm encryption-config.yaml


ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
echo " # Generated encryption key ENCRYPTION_KEY=${ENCRYPTION_KEY:0:8}"
cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

echo " # Distribute encryption config to control plane nodes"
for instance in controller-0 controller-1 controller-2; do
    echo " # Distributing to ${instance}"
    gcloud compute scp encryption-config.yaml ${instance}:~/
done
#!/bin/bash
set -e

# ===== CONFIG =====
EC2_HOST="ubuntu@65.0.65.123"
EC2_KEY="~/Desktop/Develeap/Develeap-Course/lavagna/lavagna.pem"
VERSION="${1:-1.0}"
AWS_ACCOUNT_ID="167918485905"
AWS_REGION="ap-south-1"

PACKAGE_DIR="lavagna-startup-package_${VERSION}"
PACKAGE_TAR="${PACKAGE_DIR}.tar.gz"

echo "Deploying version: ${VERSION}"

# ===== 1. Build image & push to ECR =====
./build.sh ${VERSION}

# ===== 2. Upload package to EC2 =====
echo "Uploading package to EC2..."
scp -i "${EC2_KEY}" "${PACKAGE_TAR}" "${EC2_HOST}:~"

# ===== 3. Deploy on EC2 =====
echo "Deploying on EC2..."
ECR_PASSWORD=$(aws ecr get-login-password --region ${AWS_REGION})
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

ssh -i "${EC2_KEY}" ${EC2_HOST} "
  echo \"${ECR_PASSWORD}\" | docker login --username AWS --password-stdin ${ECR_REGISTRY}
  rm -rf ${PACKAGE_DIR}
  tar -xzvf ${PACKAGE_TAR}
  cd ${PACKAGE_DIR}
  ls -la nginx/
  chmod +x startup.sh
  APP_TAG=${VERSION} ./startup.sh
"

echo "Deployment completed successfully!"

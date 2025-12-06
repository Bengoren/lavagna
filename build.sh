#!/bin/bash
set -e

# Version tag provided by the user (default = 1.0)
VERSION="${1:-1.0}"

AWS_ACCOUNT_ID="167918485905"
AWS_REGION="ap-south-1"
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/lavagna"

PACKAGE_DIR="lavagna-startup-package_${VERSION}"
PACKAGE_TAR="${PACKAGE_DIR}.tar.gz"

echo "=== Building Lavagna ${VERSION} ==="

# 1. Build Docker image
docker build -t lavagna:${VERSION} .

# 2. Tag image for ECR
docker tag lavagna:${VERSION} ${ECR_REPO}:${VERSION}

# 3. Login to ECR
aws ecr get-login-password --region ${AWS_REGION} \
  | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# 4. Push image to ECR
docker push ${ECR_REPO}:${VERSION}

# 5. Create startup package folder
rm -rf "${PACKAGE_DIR}"
mkdir "${PACKAGE_DIR}"

# Copy required deployment files
cp docker-compose.yaml startup.sh "${PACKAGE_DIR}/"
mkdir -p "${PACKAGE_DIR}/project"
cp -r project/. "${PACKAGE_DIR}/project/"
cp -r nginx "${PACKAGE_DIR}/"

# 6. Create compressed package
# Remove macOS metadata files to prevent tar errors on Linux
find "${PACKAGE_DIR}" -name "._*" -delete
find "${PACKAGE_DIR}" -name ".DS_Store" -delete

COPYFILE_DISABLE=1 tar --exclude='._*' --exclude='.DS_Store' -czvf "${PACKAGE_TAR}" "${PACKAGE_DIR}"

echo "=== Done! ==="
echo "Created: ${PACKAGE_TAR}"
echo "Pushed image: ${ECR_REPO}:${VERSION}"

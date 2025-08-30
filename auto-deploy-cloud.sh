#!/bin/bash
set -e

# ----------------------------
# CONFIG
# ----------------------------
SCANZACLIP_DIR=~/projects/scanzaclip
CLOUD_ANDROID_REPO=https://github.com/Outsideking/cloud-android-web.git
CLOUD_ANDROID_DIR=$SCANZACLIP_DIR/backend/services/cloud-android-web
AWS_REGION="ap-southeast-2"
ECR_REPO="cloud-android-web"
CLUSTER_NAME="scanzaclip-cluster"
SERVICE_NAME="cloud-android-service"
TASK_DEF="cloud-android-task"

echo "🚀 เริ่ม Auto Integration + Deploy to AWS ECS"

# 1. clone หรือ update cloud-android-web
if [ ! -d "$CLOUD_ANDROID_DIR" ]; then
  echo "📥 กำลัง clone cloud-android-web..."
  git clone $CLOUD_ANDROID_REPO $CLOUD_ANDROID_DIR
else
  echo "🔄 อัปเดต cloud-android-web..."
  cd $CLOUD_ANDROID_DIR && git pull origin main
fi

# 2. Login ECR
echo "🔑 กำลัง Login AWS ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 3. Build + Push Docker image
cd $CLOUD_ANDROID_DIR
docker build -t $ECR_REPO .
docker tag $ECR_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest

echo "📦 Push image ไปที่ AWS ECR เรียบร้อย"

# 4. Update Task Definition
echo "📝 สร้าง Task Definition..."
cat > task-def.json <<EOL
{
  "family": "$TASK_DEF",
  "networkMode": "awsvpc",
  "executionRoleArn": "arn:aws:iam::$AWS_ACCOUNT_ID:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "cloud-android-web",
      "image": "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:latest",
      "essential": true,
      "portMappings": [
        { "containerPort": 5000, "protocol": "tcp" }
      ]
    }
  ],
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024"
}
EOL

aws ecs register-task-definition --cli-input-json file://task-def.json

# 5. Update Service
echo "🔄 Deploy Service..."
aws ecs update-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --task-definition $TASK_DEF \
  --force-new-deployment \
  --region $AWS_REGION

echo "🎉 เสร็จสิ้น! Cloud Android Web ถูก Deploy ไปยัง AWS ECS/Fargate แล้ว"
echo "🌍 เข้าดูที่: https://$SERVICE_NAME.$CLUSTER_NAME.$AWS_REGION.amazonaws.com"

#!/bin/bash
set -e

STACK=cloud-android-web
REGION=ap-southeast-2
APP=cloud-android-web

# 1) สร้าง SSM/Secrets ค่าที่ต้องใช้ (ตัวอย่างใช้ SSM StringParameter)
#  แก้ค่าด้านล่างให้เป็นของจริงก่อนรันครั้งแรก
aws ssm put-parameter --name /cloud-android/PAYPAL_CLIENT_ID --type SecureString --value "YOUR_PAYPAL_CLIENT_ID" --overwrite --region $REGION
aws ssm put-parameter --name /cloud-android/PAYPAL_CLIENT_SECRET --type SecureString --value "YOUR_PAYPAL_CLIENT_SECRET" --overwrite --region $REGION
aws ssm put-parameter --name /cloud-android/PAYPAL_ENV --type String --value "sandbox" --overwrite --region $REGION
aws ssm put-parameter --name /cloud-android/OPN_PUBLIC_KEY --type SecureString --value "pkey_test_xxx" --overwrite --region $REGION
aws ssm put-parameter --name /cloud-android/OPN_SECRET_KEY --type SecureString --value "skey_test_xxx" --overwrite --region $REGION
# base URL จะเติมอัตโนมัติหลังรู้ ALB DNS; ตั้งชั่วคราวก่อน
aws ssm put-parameter --name /cloud-android/WEBHOOK_URL_BASE --type String --value "http://placeholder" --overwrite --region $REGION

# 2) สร้าง/อัปเดต stack
aws cloudformation deploy \
  --template-file cloud-android-ecs.yml \
  --stack-name $STACK \
  --region $REGION \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides AppName=$APP

# 3) อ่าน ECR URI + ALB DNS
ECR_URI=$(aws cloudformation describe-stacks --stack-name $STACK --region $REGION \
  --query "Stacks[0].Outputs[?OutputKey=='ECRRepoUri'].OutputValue" --output text)
ALB_DNS=$(aws cloudformation describe-stacks --stack-name $STACK --region $REGION \
  --query "Stacks[0].Outputs[?OutputKey=='ALBDNS'].OutputValue" --output text)

echo "ECR: $ECR_URI"
echo "ALB: http://$ALB_DNS"

# 4) สร้าง repo ถ้ายังไม่มี (deploy สร้างให้แล้วโดย CFN; ส่วนนี้กันกรณีพลาด)
aws ecr describe-repositories --repository-names $APP --region $REGION >/dev/null 2>&1 || \
  aws ecr create-repository --repository-names $APP --region $REGION

# 5) Login ECR + build/push image (ต้อง cd ไปโฟลเดอร์ที่มี Dockerfile ของโปรเจ็กต์)
aws ecr get-login-password --region $REGION \
  | docker login --username AWS --password-stdin ${ECR_URI%/*}
docker build -t $APP .
docker tag $APP:latest $ECR_URI:latest
docker push $ECR_URI:latest

# 6) บังคับ service rollout
CLUSTER=$(aws cloudformation describe-stacks --stack-name $STACK --region $REGION \
  --query "Stacks[0].Outputs[?OutputKey=='ClusterName'].OutputValue" --output text)
SERVICE=$(aws cloudformation describe-stacks --stack-name $STACK --region $REGION \
  --query "Stacks[0].Outputs[?OutputKey=='ServiceName'].OutputValue" --output text)

aws ecs update-service --cluster $CLUSTER --service $SERVICE --force-new-deployment --region $REGION

# 7) อัปเดต WEBHOOK_URL_BASE ให้ชี้ ALB จริง แล้ว rollout อีกครั้ง
aws ssm put-parameter --name /cloud-android/WEBHOOK_URL_BASE --type String \
  --value "http://$ALB_DNS" --overwrite --region $REGION

aws ecs update-service --cluster $CLUSTER --service $SERVICE --force-new-deployment --region $REGION

echo "✅ เสร็จสิ้น — เปิดเว็บได้ที่: http://$ALB_DNS"
echo "🔔 ตั้ง Webhook: "
echo "   PayPal: http://$ALB_DNS/api/payments/webhook/paypal"
echo "   Omise:  http://$ALB_DNS/api/payments/webhook/opn"

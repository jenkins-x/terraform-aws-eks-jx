CLUSTER_NAME=$1

remove_quotes() {
  local VAR=$1
  echo "$VAR" | tr -d '"'
}

LBS=$(aws elb describe-load-balancers | jq ".LoadBalancerDescriptions[] | .LoadBalancerName")
echo "List of LBs: "
echo "$LBS"
for LB_OUTPUT in $LBS; do
  LB=$(remove_quotes "$LB_OUTPUT")
  aws elb describe-tags --load-balancer-names "$LB" | jq ".TagDescriptions[] | .Tags[] | .Key" | grep "$CLUSTER_NAME" > /dev/null
  if [ $? -eq 0 ]; then
    echo "Delete Load Balancer: $LB"
    aws elb delete-load-balancer --load-balancer-name "$LB"
  fi
done

SG_ID_OUTPUT=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=k8s-elb-*" "Name=tag:kubernetes.io/cluster/$CLUSTER_NAME,Values=*" | jq ".SecurityGroups[] | .GroupId")
SG_ID=$(remove_quotes "$SG_ID_OUTPUT")
echo "Delete Security Group: $SG"
EXIT_CODE=1
count=60
while [ $count -gt 0 ] && [ $EXIT_CODE -ne 0 ];
do
  aws ec2 delete-security-group --group-id "$SG_ID"
  EXIT_CODE=$?
  count=$((count-1))
  echo "Count: $count"
  echo "Exit Code: $EXIT_CODE"
  sleep 10
done

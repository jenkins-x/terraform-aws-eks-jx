CLUSTER_NAME=$1

remove_quotes() {
  local VAR=$1
  echo "$VAR" | tr -d '"'
}

VOLUMES=$(aws ec2 describe-volumes --filters "Name=tag:kubernetes.io/cluster/$CLUSTER_NAME,Values=owned" --filters Name=status,Values=available | jq ".Volumes[] | .VolumeId")
for VOLUME_OUTPUT in $VOLUMES; do
  VOLUME=$(remove_quotes "$VOLUME_OUTPUT")
  echo "Delete Volume: $VOLUME"
  aws ec2 delete-volume --volume-id "$VOLUME"
done

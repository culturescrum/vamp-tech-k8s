#!/usr/bin/env bash
source .env
echo "Setting up kubernetes cluster '${DROPLET_SLUG}'"

WORKERS=${1:-4}
echo ${WORKERS} > .node_count
echo "Creating master node (${DROPLET_SLUG}-master)"
MASTER_HOST=$(doctl compute droplet create ${DROPLET_SLUG}-master --region ${DO_REGION} --image ${IMAGE_SLUG} --size ${MASTER_SIZE} --enable-private-networking --ssh-keys ${DO_SSH_KEY} --wait --no-header --format PublicIPv4)
MASTER_ENTRY="master ansible_host=${MASTER_HOST} ansible_user=root"

cat << EOF > hosts
[masters]
${MASTER_ENTRY}

[workers]
EOF

for (( NODE_NUM=1; NODE_NUM<=$WORKERS; NODE_NUM++ )); do
  echo "Creating worker node (${DROPLET_SLUG}-worker${NODE_NUM})"
  declare WORKER_$NODE_NUM=$(doctl compute droplet create ${DROPLET_SLUG}-worker${NODE_NUM} --region ${DO_REGION} --image ${IMAGE_SLUG} --size ${NODE_SIZE} --enable-private-networking --ssh-keys ${DO_SSH_KEY} --wait --no-header --format PublicIPv4)
  WORKER_NODE=WORKER_$NODE_NUM
  WORKER_ENTRY="${WORKER_ENTRIES}worker${NODE_NUM} ansible_host=${!WORKER_NODE} ansible_user=root"
  echo ${WORKER_ENTRY} >> hosts
done

cat << EOF >> hosts

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

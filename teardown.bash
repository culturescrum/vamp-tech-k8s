#!/usr/bin/env bash
source .env
WORKERS=$(cat .node_count || echo -n 4)
echo "Tearing down kubernetes cluster '${DROPLET_SLUG}'"
CMD="doctl compute droplet rm ${DROPLET_SLUG}-master ${DROPLET_SLUG}-worker{1..${WORKERS}} -f"
eval $CMD
rm .node_count

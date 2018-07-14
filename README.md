# vamp-tech k8s

## Host config
### Example Using DigitalOcean

- master
  - size: s-3vcpu-1gb
- nodes:
  - size: s-1vcpu-2gb
  - 4 total

#### Setup

Create the hosts:

```bash
DROPLET_SLUG=example-k8s
IMAGE_SLUG=ubuntu-16-04-x64
DO_SSH_KEY=123456
DO_REGION=nyc3
MASTER_SIZE=s-3vcpu-1gb
NODE_SIZE=s-1vcpu-2gb

# Creates:
# - example-k8s-master
# - example-k8s-node01
# - example-k8s-node02
# - example-k8s-node03
# - example-k8s-node04
doctl compute droplet create ${DROPLET_SLUG}-master --region ${DO_REGION} --image ${IMAGE_SLUG} --size ${MASTER_SIZE} --enable-private-networking --ssh-keys ${DO_SSH_KEY} --wait
doctl compute droplet create ${DROPLET_SLUG}-node{01,02,03,04} --region ${DO_REGION}  --image ${IMAGE_SLUG} --size ${NODE_SIZE} --enable-private-networking --ssh-keys ${DO_SSH_KEY} --wait
```


Update IP Addresses:

```bash
doctl compute droplet list --format Name,PublicIPv4 | grep ${DROPLET_SLUG}
 example-k8s-master  123.45.67.89
 example-k8s-node03  123.45.67.122
 ...
```

Update IP values (workers are nodes) in `hosts` file.

Execute the playbooks:

```bash
# I'm bad but I don't feel that bad.
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook host-init.yml && \
  ansible-playbook kube-install.yml && \
  ansible-playbook kube-init.yml && \
  ansible-playbook worker-init.yml
# If you want to retrieve the kubeconfig after this point:
ansible-playbook get-kubeconfig.yml
export KUBECONFIG=kubeconfig/master/etc/kubernetes/admin.conf
```

If you want to use the dashboard, I recommend starting here: https://github.com/kubernetes/dashboard

The quick way to get access is to setup a service account in the default namespace (don't supply it, basically), and create a clusterrolebinding with the clusterrole set to "cluster-admin" and then an identical "rolebinding". Get the secret (`kubectl get secrets` then `kubectl describe <token name>`).

Once you've got the token handy, `kubectl proxy`, then click the `localhost` link in the above dashboard README.md. Use "Token" authentication and copy-paste the token.

See the following for setting up persistent storage in DO:

- https://stackpointcloud.com/community/tutorial/getting-started-with-digitalocean-block-storage-and-kubernetes
- https://github.com/kubernetes-incubator/external-storage/tree/master/digitalocean

#### Teardown

Destroy it all:

```bash
doctl compute droplet rm ${DROPLET_SLUG}-master ${DROPLET_SLUG}-node{01,02,03,04} -f
```

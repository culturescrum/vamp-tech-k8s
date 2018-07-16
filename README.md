# vamp-tech k8s

## Host config
### Example Using DigitalOcean

- master
  - size: s-3vcpu-1gb
- nodes:
  - size: s-1vcpu-2gb
  - 4 total

#### Setup

The below steps assume you have `doctl` installed and configured with a write-access key. This is outside of the scope of this README.

##### Create the hosts

```bash
cp example.env .env
# edit .env values
# default, build 1 master, 4 workers
./build_inventory.bash
# build 1 master, 6 workers
./build_inventory.bash 6
```

This will stand up the nodes in DigitalOcean using doctl.

It will also create a `hosts` inventory file with all of the IPs of the new nodes pre-configured, which you can edit before you run the playbooks.

##### Execute the playbooks

```bash
# I'm bad but I don't feel that bad.
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook host-init.yml && \
  ansible-playbook kube-install.yml && \
  ansible-playbook kube-init.yml && \
  ansible-playbook worker-init.yml
# If you want to retrieve the kubeconfig after this point:
ansible-playbook get-kubeconfig.yml
export KUBECONFIG=kubeconfig/master/etc/kubernetes/admin.conf
kubectl get nodes
```

##### Things to do next

If you want to use the Kubernetes dashboard, I recommend starting here: https://github.com/kubernetes/dashboard

The quick way to get access is to setup a service account in the default namespace (don't supply it, basically), and create a clusterrolebinding with the clusterrole set to "cluster-admin" and then an identical "rolebinding". Get the secret (`kubectl get secrets` then `kubectl describe <token name>`).

Once you've got the token handy, `kubectl proxy`, then click the `localhost` link in the above dashboard README.md. Use "Token" authentication and copy-paste the token.

See the following for setting up persistent storage in DO:

- https://stackpointcloud.com/community/tutorial/getting-started-with-digitalocean-block-storage-and-kubernetes
- https://github.com/kubernetes-incubator/external-storage/tree/master/digitalocean

#### Teardown

Destroy it all:

```bash
./teardown.bash
```

### TODO

- [ ] Refactor into roles
- [ ] Script out hostkey retrieval
- [ ] Refactor scripts into functions & move to `scripts/`

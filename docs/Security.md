# Security

## Secrets

Storing secrets in a GitOps repository is to be avoided. The Flux provides support decryption of secrets using SOPS. The age utility is used to generate the keys used for SOPS encryption.

This section covers the management of two secrets required in the provisioning process:

- Hypervisor credentials: One credential per target cluster, installed on the Management Cluster.
- Git credentials for GitOps repositories: One credential per target cluster, installed on the Target Cluster.

## Generating the secrets

### Hypervisor credentials

In a production environment, a user with only the roles required to operate the cluster provisioning solution should be created.

For illustration, the secret required for the Proxmox Cluster API Infrastructure provider has the following form:

- `cluster09-proxmox-secret.yaml`:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  labels:
    cluster.x-k8s.io/provider: infrastructure-proxmox
    clusterctl.cluster.x-k8s.io: ""
    platform.ionos.com/secret-type: proxmox-credentials
  name: capmox-manager-credentials
  namespace: cluster09
stringData:
  secret: <PROXMOX TOKEN>
  token: <root@pam!root>
  url: https://192.168.4.50:8006
```

### GitOps credentials

The secret required for flux to bootstrap a cluster by connecting to your GitOps repo can be generated using the flux cli:

`flux create secret --export git cluster09 --url=https://github.com/MoTTTT/cluster09.git  --username=martinjcolley@gmail.com  --password=<GIT_TOKEN> > cluster09-flux-secret.yaml`

## Operations

### Software Installation and key generation

- Install sops: `sudo apt install sops`
- Install age: `sudo apt install age`
- HINT: Create a new directory to work in, and delete it after use.
- Generate key: `age-keygen -o age.agekey`
- This returns an `<AGE_KEY>`, the public key used for encryption in the commands below. It is also in the generated file.
- The public key can be saved in the GitOps repo, in this case `.sops.public.key`, for use to encrypt any workload secrets required for GitOps.

### Encryption of secrets

- Encrypt proxmox credentials: ``sops --age=<AGE_KEY> --encrypt --encrypted-regex '^(data|stringData)$' --in-place cluster09-proxmox-secret.yaml`
- Encrypt flux git token: `sops --age=<AGE_KEY> --encrypt --encrypted-regex '^(data|stringData)$' --in-place cluster09-flux-secret.yaml`

### Installation of age key onto clusters

- If GitOps is working as intended, and a cluster does not need any petting, the need to for direct use of the kubernetes api is limited to the installation of private keys.
- Ideally, a cluster start-up pod could generate the necessary keys, and install them onto the cluster, publishing the public key.
- Install secret: `cat age.agekey | kubectl create secret generic sops-age --namespace=flux-system --from-file=age.agekey=/dev/stdin`

### Inclusion of encrypted secrets into GitOps repos



## Network

- Bastion server: See `Bastion.md`
- Port forwarding
- Gateway

## Reference

- <https://fluxcd.io/flux/guides/mozilla-sops/>
- <https://github.com/getsops/sops>
- <https://github.com/FiloSottile/age>

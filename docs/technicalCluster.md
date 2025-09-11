# Microk8s

## Decisions

- Microk8s Kubernetes distribution
- Build tools (kubectl, calicoctl, ansible etc) on dolmen workstation
- k8s IOT Edge on anasazi RPi
- Implement ceph distributed storage - Migrate from nfs on sigiriya
- Secure ingress host based routing

## Network

- Fibre router: Static IPs for control plane and worker nodes
- Fibre router: (As-is) Dynamic DNS for ```qsolutions.endoftheinternet.org```
- Fibre router: Port forwarding: 443 to k8s L2 load-balancer (As-is goes to dolmen)
- Fibre router: Restrict DHCP IP allocation range for clients to `192.168.0.2 - 192.168.0.120`
- MetalLB: IP address range: `192.168.0.131-192.168.0.140`
- DynDns: Update IP address using ddclient
- To dev, test and debug ingress, add: qapps.does-it.net

## Cluster installation and configuration

On each node, run `sudo snap install microk8s --channel=1.30/stable --classic`

On the master node, run `sudo microk8s add-node` (once for each of the other node), and run the resulting join command on the other node.
This can be automated with ansible.

Then, on any node, run:

- `sudo microk8s enable metrics-server`
- `sudo microk8s enable rook-ceph`; See technicalCeph.md for more details
- `sudo microk8s connect-external-ceph`; Run this on the same node that microceph running.
- `sudo microk8s enable metallb`
- `sudo microk8s enable cert-manager`

The following has been migrated to flex, together with cluster infrastructure components:

- `sudo microk8s helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace`
- NOTE: This gives `ingressClassName: nginx`

## Infrastructure Test: musings over https with git-sync

An installation of static-site, with default configuration (musings):

NOTE: WAN port forwarding to the metallb IP address is required for certificates to be issued.

```bash
helm  install musings-01 --debug  --namespace musings --create-namespace static-site --repo 'https://dl.cloudsmith.io/public/q-solutions/static-site/helm/charts/'
```

This install tests the following cluster capabilities:

- L2 load balancer
- Ingress
- Certificate Manager

To install podzone docs:

```bash
helm  install podzone-01 --debug  --namespace podzone --create-namespace static-site --repo 'https://dl.cloudsmith.io/public/q-solutions/static-site/helm/charts/' --values valuespodzone.yaml
```

## Ceph configuration

- `microk8s enable rook-ceph`; See technicalCeph.md for more details
- `microk8s connect-external-ceph --ceph-conf ceph.conf --keyring ceph.keyring --rbd-pool microk8s_rbd`

## Rolling maintenance

In order to upgrade the nodes of the cluster, take one node out of service at a time.

- Take a node out of service: `kubectl drain --ignore-daemonsets --delete-emptydir-data <node name>`
- `--delete-emptydir-data` is required if use is made of local storage.
- To bring the node back in to the cluster: `kubectl uncordon <node name>`

### Cluster substrate maintenance

**Cluster substrate** here refers to kubernetes distribution installation, in this case Canonical's *MicroK8s*, including any add-ons. `Canonical: Practically, as soon as the admin enables an addon he is expected to own its maintenance. We are offering new versions of the addon enable/disable scripts and in order to get them the admin would need to microk8s addons repo update <repo>` Reference: <https://github.com/canonical/microk8s-core-addons/issues/255>.

## Libretime Helm Chart implications

The following section is copied from Helm chart documentation, at <https://github.com/MoTTTT/libretime-helm/blob/main/AnalysisNotes.md>, and should be read in the context of the libretime workload.

The **Cluster Substrate** is an environmental dependency for the repeatable functioning of the libretime helm chart. Testing of the chart has been done on the following environment:

- Minimum server configuration: Single node k8s "cluster".
- Operating system: Ubuntu 22.04 minimised.
- Kubernetes storage volumes: MicroCeph. Used for the postgres database in the libretime use-case.
- NFS storage for media input, media storage, and database backups.
- Microk8s {channel 1.30/stable, channel 1.30/stable}, with the following add-ons enabled and configured:
  - `metrics-server`: For exposing cpu and ram usage metrics.
  - `cert-manager`: For providing https certificates to the cluster.
  - `metallb`: A cluster load balancer for traffic from the Internet, from a port forwarded on the Internet gateway.
  - `rook-ceph`: For supporting ceph storage to the cluster.
  - `connect-external-ceph`: This is a microk8s command that can be run once the *rook-ceph* add-on is enabled, to enable the consumption of the external Microceph volume for the database.
  - `ingress-nginx`: For supporting cluster level listeners for Internet traffic.

### Repeatable automated build from Bare Metal on a unit scale

The choice of repeatability of deployment from *Bare Metal* is driven by the interest in self-hosted solutions. With the growing acceptance of Kubernetes as a generalised computing substrate, coupled with support in the Kubernetes ecosystem for GitOps, there is opportunity for abstracting entire solutions into a single set of files, in a naturally change-controlled way.

If the cluster is bootstrapped with a flex repo after a clean Microk8s install, all the above configuration can be managed using GitOps. For the dev environment build, the public repo at <https://github.com/MoTTTT/podzonedev-gitops.git> can be cloned and adjusted for local off cluster infrastructure dependencies before bootstrapping a cluster with flex.

The notion of bootstrapping the cluster for GitOps before any add-ons or configuration is attractive. So the candidate gitops repo can be cloned to provide the minimum configuration repeatable install from bare metal on a unit scale, that configures the environment, and then deploys the radio chart.

Scaling out involves joining nodes to the cluster using microk8s CLI, but a design goal is for a single node cluster to work for the purposes of ensuring an efficient, repeatable development, quality assurance, or production environment.

## Ubuntu unattended-updates

Most of the time the unattended-updates feature in Ubuntu works well without evidence or artefacts.

However, over the course of two phases of a project, microk8s nodes became broken to the extent that five out of ten nodes were not starting up, and off the network.

Initial assumptions indicating SATA SSD failure (hardware tests failing, over-interpretation of M.2 module led colouring, etc), followed by motherboard failure (unable to boot a freshly installed OS on a new SSD) were wrong. False negatives due to DisplayPort behaviour over-interpretation added to the inaccuracy of these assumptions.

With the assistance of the HP T630 BIOS diagnostics, unit level issues were eliminated, as were SSD and RAM. This also exposed DisplayPort inconsistent behaviour. Even cold start did not give consistent DisplayPort behaviour introduced during a failed boot.

In any case the issue was identified to be apparent in a specific linux kernel that had been introduced during unattended-updates.

### Specifying linux kernel version on Ubuntu 22.04 Server minimised installation

- To access the grub boot menu, press right-shift at power up.
- You can at this stage try the current kernel in recovery mode, or a previous kernel.
- Note that a previous kernel will not be an option on a fresh install, even from an old Ubuntu Server 22.04 USB drive, if the machine was on the network during install.
- Note also that selecting `no` to using the latest installer, and also cancelling the update at the end of the installation only leaves the newest kernel in place.
- However, if the kernel does boot in recovery mode of the only kernel, a known-good kernel for your hardware can be installed (together with the matching headers package).
- Once you have a kernel that works (in all modes) installed, you can set grub up to boot to the last selected mode as follows:
- Set the following in `/etc/default/grub`

```
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
```

- On a minimised install, you may need to install an editor, or use sed and echo to achieve these changes.
- Reload grub: `sudo update-grub`
- Reboot with grub menu, select preferred kernel, allow boot to finish, and then reboot as normal to test.

## OS Installation

- USB Installer: Ubuntu Server Minimized 22.04.03
- Use MoTTTT GitHub account to pull authorized_keys
- Set time-zone: `sudo timedatectl set-timezone Europe/London`
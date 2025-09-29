# Storage

## ZFS storage configuration on hypervisor

- Hypervisor storage resources: 8 X 600GB SAS Disk, configured in IT mode
- 1 Disk assigned to hypervisor (no redundancy, SPOF)
- 7 disks configured in raid 0 array (Any of 7 disks SPOF)
- Optimising for disk utilisation, and speed
- Optimising for cluster build repeatability

### Example Raid 0 configuration

- List available volumes: `ls -la /dev/disk/by-id`
- Create pool: `zpool create pool1 wwn-0x5000cca05633e2d0 ... wwn-0x500003930821ed54`
- Add pool: `pvesm add zfspool pool1 -pool pool1`

## Distributed storage

- Using in-cluster Linstor

### Linstor installation

- Check talos extensions: `talosctl --talosconfig=./talosconfig --endpoints 192.168.4.114 --nodes 192.168.4.114 get extensions`
- Check talos loaded modules: `talosctl --talosconfig=./talosconfig --endpoints 192.168.4.114 --nodes 192.168.4.114 read /proc/modules`
- Check talos drbd config: `talosctl --talosconfig=./talosconfig --endpoints 192.168.4.114 --nodes 192.168.4.114 read /sys/module/drbd/parameters/usermode_helper`
- `kubectl apply --server-side -k "https://github.com/piraeusdatastore/piraeus-operator/config/default?ref=v2.8.1"`

Apply overrides:

```yaml
apiVersion: piraeus.io/v1
kind: LinstorSatelliteConfiguration
metadata:
  name: talos-loader-override
spec:
  podTemplate:
    spec:
      initContainers:
        - name: drbd-shutdown-guard
          $patch: delete
        - name: drbd-module-loader
          $patch: delete
      volumes:
        - name: run-systemd-system
          $patch: delete
        - name: run-drbd-shutdown-guard
          $patch: delete
        - name: systemd-bus-socket
          $patch: delete
        - name: lib-modules
          $patch: delete
        - name: usr-src
          $patch: delete
        - name: etc-lvm-backup
          hostPath:
            path: /var/etc/lvm/backup
            type: DirectoryOrCreate
        - name: etc-lvm-archive
          hostPath:
            path: /var/etc/lvm/archive
            type: DirectoryOrCreate
```

Create Linstor cluster:

```yaml
apiVersion: piraeus.io/v1
kind: LinstorCluster
metadata:
  name: linstorcluster
spec: {}
```

Check node list: `kubectl -n piraeus-datastore exec deploy/linstor-controller -- linstor node list`

Configure storage:

```yaml
apiVersion: piraeus.io/v1
kind: LinstorSatelliteConfiguration
metadata:
  name: storage-pool
spec:
  storagePools:
    - name: pool1
      fileThinPool:
        directory: /var/lib/piraeus-datastore/pool1
```

Check storage pool: `kubectl -n piraeus-datastore exec deploy/linstor-controller -- linstor storage-pool list`

Create storage class:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: piraeus-storage
provisioner: linstor.csi.linbit.com
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
parameters:
  linstor.csi.linbit.com/storagePool: pool1
```

Replicated storage class:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: piraeus-storage-replicated
provisioner: linstor.csi.linbit.com
allowVolumeExpansion: true
volumeBindingMode: WaitForFirstConsumer
parameters:
  linstor.csi.linbit.com/storagePool: pool1
  linstor.csi.linbit.com/placementCount: "2"
```

Snapshots: <https://piraeus.io/docs/stable/tutorial/snapshots>

Deploy snapshot controller

```bash
kubectl apply -k https://github.com/kubernetes-csi/external-snapshotter//client/config/crd
kubectl apply -k https://github.com/kubernetes-csi/external-snapshotter//deploy/kubernetes/snapshot-controller
```

Create SnapshotClass

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: piraeus-snapshots
driver: linstor.csi.linbit.com
deletionPolicy: Delete
```

Create VolumeSnapshot

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: data-volume-snapshot-1
spec:
  volumeSnapshotClassName: piraeus-snapshots
  source:
    persistentVolumeClaimName: data-volume
```

Affinity controller:

`helm repo add piraeus-charts https://piraeus.io/helm-charts/`
`helm install linstor-affinity-controller piraeus-charts/linstor-affinity-controller`

Monitoring with Prometheus operator:

Install prometheus:

`$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`

```bash
helm install --create-namespace -n monitoring prometheus prometheus-community/kube-prometheus-stack \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false
```

Add monitoring and alert rules for piraeus:

```bash
kubectl apply --server-side -n piraeus-datastore -k "https://github.com/piraeusdatastore/piraeus-operator//config/extras/monitoring?ref=v2"
```

## Switching to gitops

- `flux create source helm piraeus-charts  --url=https://prometheus-community.github.io/helm-charts --interval=10m --export`
- `flux create hr affinity-controller  --interval=10m  --source=HelmRepository/piraeus-charts  --chart=linstor-affinity-controller --export`
- See gitops-infra for manifests.

## References

- Reference: <https://piraeus.io/docs/stable/tutorial/get-started>

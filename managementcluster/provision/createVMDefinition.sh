#/bin/bash

clusterID=control-cluster
proxmoxnode=venus
proxmoxurl=https://192.168.4.50:8006/
proxmoxuser=root@pam
proxmoxpass=XXXXXXX
concontrolPlaneIPAddress=192.168.4.200
concontrolPlaneIPAddresses='192.168.4.201'
workerIPAddresses='192.168.4.205'
gateway=192.168.4.1
bridge=vmbr0
pool=pool1
talosImageID=6adc7e7fba27948460e2231e5272e88b85159da3f3db980551976bf9898ff64b
talosVersion=v1.11.1
bastionIP=192.168.1.80
bastionHost=freyr
bastionPort=6449

mkdir vms || true
sed -e "s/TALOSIMAGEID/${talosImageID}/g" -e "s/CLUSTER/${clusterID}/g" -e "s/TALOSVERSION/${talosVersion}/g" files.template > vms/files.tf
sed -e "s|PROXMOXURL|${proxmoxurl}|g" -e "s/PROXMOXUSER/${proxmoxuser}/g" -e "s/PROXMOXPASS/${proxmoxpass}/g" providers.template > vms/providers.tf

i=1
for concontrolPlaneIPAddress in ${concontrolPlaneIPAddresses}; do
    sed -e "s/CLUSTER/${clusterID}/g" -e "s/NODEID/${i}/g" -e "s/PROXMOXNODE/${proxmoxnode}/g" -e "s/BRIDGE/${bridge}/g" \
        -e "s/NODEIP/${concontrolPlaneIPAddress}/g" -e "s/GATEWAY/${gateway}/g" -e "s/POOL/${pool}/g" controlplaneVM.template > vms/cp${i}.tf
    i=$((i + 1))
done

i=1
for workerIPAddress in ${workerIPAddresses}; do
    sed -e "s/CLUSTER/${clusterID}/g" -e "s/NODEID/${i}/g" -e "s/PROXMOXNODE/${proxmoxnode}/g" -e "s/BRIDGE/${bridge}/g" \
        -e "s/NODEIP/${workerIPAddress}/g" -e "s/GATEWAY/${gateway}/g" -e "s/POOL/${pool}/g" workerVM.template > vms/w${i}.tf
    i=$((i + 1))
done

mkdir talos || true
sed -e "s/CERTSANIP/${bastionIP}/g" -e "s/CERTSANHOST/${bastionHost}/g" -e "s/TALOSIMAGEID/${talosImageID}/g" -e "s/TALOSVERSION/${talosVersion}/g" talos-patch.template > talos/patch.yaml
cp controlplane-patch.template talos/controlplane-patch.yaml

sed -e "s/CONTROLPLANEIPS/${concontrolPlaneIPAddresses}/g" -e "s/CONTROLPLANEIP/${concontrolPlaneIPAddress}/g" -e "s/WORKERIPS/${workerIPAddresses}/g" \
    -e "s/APIPORT/${bastionPort}/g" -e "s/CERTSANHOST/${bastionHost}/g" -e "s/CERTSANIP/${bastionIP}/g" \
    -e "s/CLUSTER/${clusterID}/g" createCluster.template > talos/createCluster.sh
chmod +x talos/createCluster.sh

echo Switch to the vms directory, and run 'terraform init', followed by 'terraform apply -parallelism=1'

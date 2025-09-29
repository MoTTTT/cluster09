#/bin/bash
set -x

clusterID=control-cluster
concontrolPlaneIPAddresses='192.168.4.201'
workerIPAddresses='192.168.4.202'

talosctl gen config ${clusterID} https://192.168.4.201:6443 --config-patch @patch.yaml

talosctl machineconfig patch controlplane.yaml --patch @controlplane-patch.yaml --output controlplane-patched.yaml

for cpip in ${concontrolPlaneIPAddresses}; do
    echo Applying control plane configuration to ${cpip}
    talosctl apply-config --insecure --nodes ${cpip} --file controlplane-patched.yaml
done

for wip in ${workerIPAddresses}; do
    echo Applying worker node configuration to ${wip}
    talosctl apply-config --insecure --nodes ${wip} --file worker.yaml
done

talosctl config merge ./talosconfig
talosctl config endpoint 192.168.4.201

set +x
echo ================================ NEXT STEPS ==============================================
echo To bootstrap the cluster: talosctl bootstrap --nodes 192.168.4.201 
echo To merge API config: talosctl kubeconfig --nodes 192.168.4.201 
echo To generate API config file: talosctl kubeconfig config.control-cluster --nodes 192.168.4.201 
echo To extract etcd certificates for Prometheus monitoring: talosctl get etcdrootsecret -o yaml --nodes 192.168.4.201 
echo    and: talosctl get etcdsecret -o yaml --nodes 192.168.4.201 
echo    see https://blog.neilfren.ch/scraping-cluster-metrics-from-talos/
echo "To generate bastion API config file: sed -e 's/192.168.4.201/192.168.1.80/g' -e 's/6443/6441/g' config.control-cluster > config.control-cluster.podzone.cloud"
echo To bootstrap flux gitops: flux bootstrap github --context=admin@control-cluster --owner=MoTTTT --repository=venus --branch=main --personal --path=clusters/clustermanager01 --token-auth=true
echo To view the control talos dashboard: talosctl dashboard --nodes 192.168.4.201 
echo To add port forwarding on bastion clustermanager.podzone.cloud: iptables -t nat -A PREROUTING -i wlp2s0 -p tcp --dport 6440 -j DNAT --to-destination 192.168.4.200:6443

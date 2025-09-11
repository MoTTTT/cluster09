# Prometheus Implementation Notes

## Server installation

- `sudo snap install prometheus`: Available on localhost:9090
- `nano /var/snap/prometheus/current/prometheus.yml`

```yaml
global:
  scrape_interval:     15s
  external_labels:
    monitor: 'podzone-monitor'
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
```

## Microk8s observability

- More work required, default config needs to be overridden.

## Scraping ceph

- Enable ceph monitoring endpoints: `ceph mgr module enable prometheus`
- ceph-mgr nodes: {192.168.1.113,192.168.1.117,192.168.1.112}
- Add to prometheus config (IP addresses are for prod cluster):

```yaml
global:
  scrape_interval:     15s
  external_labels:
    monitor: 'podzone'
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'microceph'
    scrape_interval: 15s
    static_configs:
    - targets: ['192.168.1.113:9283', '192.168.1.117:9283', '192.168.1.112:9283']
```

### Reference

Prod cluster:

```text
MicroCeph deployment summary:
- antecessor (192.168.1.113)
  Services: mds, mgr, mon, osd
  Disks: 1
- erectus (192.168.1.131)
  Services: osd
  Disks: 1
- floresiensis (192.168.1.137)
  Services: osd
  Disks: 1
- habilis (192.168.1.117)
  Services: mds, mgr, mon, osd
  Disks: 1
- naledi (192.168.1.112)
  Services: mds, mgr, mon, osd
  Disks: 1
- neanderthal (192.168.1.130)
  Services: osd
  Disks: 1
- norham01 (192.168.1.140)
  Services: osd
  Disks: 1
- norham02 (192.168.1.141)
  Services: osd
  Disks: 1
- norham03 (192.168.1.142)
  Services: osd
  Disks: 1
- norham04 (192.168.1.143)
  Services: osd
  Disks: 1
```

## References

- <https://apim.docs.wso2.com/en/4.0.0/reference/k8s-operators/k8s-api-operator/>
- <https://operatorhub.io/operator/api-operator>
- <https://github.com/grafana/grafana-operator>
- <https://github.com/prometheus-operator/prometheus-operator>

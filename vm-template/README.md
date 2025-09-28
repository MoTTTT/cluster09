# Talos Template creation

This is a method of creating a VM template for use with Clauter API.

There are arguably better methods, like scripting against the Proxmox API.

This method is used because it is based on a pre Cluster API provisioning method that was used.

## Pre-requisites

- terraform installation
- Determine the Talos image required, and load it into the resource server.
- Tested with schematic ID: 6adc7e7fba27948460e2231e5272e88b85159da3f3db980551976bf9898ff64b
- Talos image config item: Nocloud
- Talos image config item: amd64
- Talos extensions: siderolabs/drbd, siderolabs/qemu-guest-agent

Resulting customization specification:

```yaml
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/drbd
            - siderolabs/qemu-guest-agent 
```

Resulting image: <https://factory.talos.dev/image/6adc7e7fba27948460e2231e5272e88b85159da3f3db980551976bf9898ff64b/v1.11.1/nocloud-amd64.iso>

Take note of the installation image for use in the Cluster API cluster template. In this case, it is <factory.talos.dev/nocloud-installer/6adc7e7fba27948460e2231e5272e88b85159da3f3db980551976bf9898ff64b:v1.11.1>.

## Usage

- Edit files.tf, correcting the talos image required. I use a local web server for image and manifests. The URL from Talos Image factory can be used directly.
- Edit providers.tf, correcting the details for the proxmox host
- Edit vm.tf, setting defaults for the the CPU, RAM and Disk
- Run `terraform init`
- Run `terraform apply`
- Once the VM is running, check that is is in maintenance mode.
- Stop the VM
- Convert the VM to a VM template
- Delete the CloudInit drive from the template (Cluster API will create this on it's own)
- Note the VM ID, for use in the Cluster API configuration%                                            
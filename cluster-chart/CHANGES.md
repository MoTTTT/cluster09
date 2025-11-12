# Changes

## TODO

- [ ] Extract talos patches into values file
- [ ] SOPS for secrets. Potential candidates: Proxmox credentials; Flux GIT token.
- [X] Roll cluster-chart into cluster09

## Issues

- [ ] Name and Namespace not rendering correctly

## Versions

- [ ] Debug name and namespace

### V0.1.9

- Retest harbor mirror config, added entries for `machine.registries.mirrors` to `talosconfigtemplate.yaml`, and `taloscontrolplane.yaml` template files.

## Releasing charts to the repo

- Bump the version in the Chart.yaml file.
- In project root directory, run: `helm package cluster-chart`
- A new tgz file is created.
- Run `helm repo index .` to update the `index.yaml` file.
- Check in, and merge into gh-pages.

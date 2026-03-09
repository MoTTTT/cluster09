# Requirements: Connectivity Recovery

## Problem
Access to the Management Cluster API at `192.168.4.170:6443` is returning "no route to host" when queried from `freyr`.

## Goal
Restore kubectl connectivity to the Management Cluster to allow CAPI resource validation and secret retrieval.

## Strategy
1. **Infrastructure Check**: Confirm the control plane node for the Management cluster is running on Proxmox.
2. **Network Routing**: Verify routing tables on `freyr` for the `192.168.4.0/24` subnet.
3. **VIP Status**: Check if the Kube-VIP (192.168.4.170) is correctly bound to a control plane node.

---
*Assigned to: 🦉 OpenClaw*

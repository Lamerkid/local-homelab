#!/bin/bash

wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
sudo mkdir /var/lib/libvirt/base-image/
sudo cp noble-server-cloudimg-amd64.img /var/lib/libvirt/base-image/base-ubuntu24.qcow2
rm noble-server-cloudimg-amd64.img

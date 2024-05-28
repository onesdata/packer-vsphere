#cloud-config

# Copyright 2023-2024 Broadcom. All rights reserved.
# SPDX-License-Identifier: BSD-2

# Ubuntu Server 24.04 LTS

autoinstall:
  version: 1
  apt:
    geoip: true
    preserve_sources_list: false
    primary:
      - arches: [amd64, i386]
        uri: http://archive.ubuntu.com/ubuntu
      - arches: [default]
        uri: http://ports.ubuntu.com/ubuntu-ports
  early-commands:
    - sudo systemctl stop ssh
  locale: ${vm_guest_os_language}
  keyboard:
    layout: ${vm_guest_os_keyboard}
${storage}
${network}
  identity:
    hostname: ubuntu-server
    username: ${build_username}
    password: ${build_password_encrypted}
  ssh:
    install-server: true
    allow-pw: true
    authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+ZHOSAAVhmyDp5jeYZRml2AhcWYXCuMYUIh90Z0GeonNdd7f977yhNPkiKswO2/qeXbiUjzVgu5+7gwhgO4FKJsGihm++7hvWzm8kvzYylq2yCHwn0MclTUpS2bLWPIE6BF+i3geomm/05278Df3HzbovqYzRhG1TQiLVV/ffrRSxD4bOCDyrxdD3mF6IkA5K/9JR73LtMFb1r3o63vBfLwZPh0ZQPW0T0Ts0kulUbisKFVhHb3qEVAMwOH/uS5vk8yLMIywLNcIcuI8TgjCHmJ7Oq+8Y/2SEGkRB/lACxUoaTKiOsudF+Hz4u6+A+ErlV8GAz2fXYUPOs7oUxYGiIfMjjnjh1Tbw442rwWozY2UxAEfjK9Opv7CkraHVGI+6tdeZFECGHmxIFqHEn4af9pQtdYvJ9LDo22vQXFeshQCWtq5A1UpB6K6h629aGE3nOb06XULHOwUIvgbsfkK9nAef/rM+rGG4o9jOQSpfKWWX3di9Y8dutwabuAukCG7GYtKU79NZV2/70r8o9oEt9Yd1G3UJGxNFhRDqe6mfREwrJ74SNhR3SBkPaGXr9yp9vqLZZmhhBzqaozY9Ip7XKdEfk8pye0/0YXevebbnIri8y7TcQSjsdpKr4L2GhhoVsHWMMpRoxUbOC7G1N25KndX3RjknvUVMUITEpwmL1Q== packer@onestic.com
  packages:
    - openssh-server
    - open-vm-tools
    - cloud-init
%{ for package in additional_packages ~}
    - ${package}
%{ endfor ~}
  user-data:
    disable_root: true
    timezone: ${vm_guest_os_timezone}
  late-commands:
    - sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /target/etc/ssh/sshd_config
    - echo '${build_username} ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/${build_username}
    - curtin in-target --target=/target -- chmod 440 /etc/sudoers.d/${build_username}

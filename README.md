# cloud-init-template

A small, reproducible template for using Ubuntu cloud-init configuration in a
local QEMU virtual machine.

The repo provides:

- `user-data`, `meta-data`, and `vendor-data` NoCloud seed files
- `just` recipes for downloading and booting an Ubuntu cloud image
- a Nix/direnv development shell with QEMU, Python, `just`, and `cloud-init`

## Why

This template is for running cloud-init directly, without first building and
publishing a VM image.

- Compared with building a Vagrant box, this keeps the tooling scope smaller:
  edit `user-data`, reboot the upstream Ubuntu cloud image, and inspect the
  result.
- Compared with Quickemu, the VM launch is more explicit and scriptable: the
  image source, automated startup, and validation live in the repo.
- Compared with heavier image-builder workflows, there is no separate artifact
  pipeline. The cloud image is downloaded on demand, and the customization stays
  in cloud-init files.

## Requirements

- Linux host with QEMU support
- Nix with flakes enabled
- direnv

## Quick Start

```sh
git clone https://github.com/batieman/cloud-init-template.git
cd cloud-init-template
direnv allow
```

Start the local HTTP server that exposes the cloud-init files:

```sh
http:start
```

In another terminal, boot the VM:

```sh
just run
```

For a graphical desktop session, use:

```sh
just run-gui
```

To exit the serial console, press `Ctrl-a x`.

## Default VM Configuration

The sample `user-data` installs `xubuntu-desktop-minimal`, creates
`/mnt/share`, and mounts the host `share/` directory into the guest with 9p.

The default cloud-init password is intentionally set to `password` for local
testing only. Change it before adapting this template for any networked,
shared, or long-lived machine.

## Useful Commands

```sh
just --list
just validate
just clean
```

`just validate` runs cloud-init schema validation against `user-data`.
`just clean` removes the downloaded cloud image.

## Repository Layout

```text
.
├── user-data       # cloud-init user-data
├── meta-data       # NoCloud instance ID and hostname
├── vendor-data     # optional NoCloud vendor data
├── justfile        # VM lifecycle commands
├── flake.nix       # Nix development shell
└── devshell.toml   # development shell command packages/services
```

## License

MIT. See [LICENSE.txt](LICENSE.txt).

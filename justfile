image := "noble-server-cloudimg-amd64.img"
base := "machine"
disk := "disk.qcow2"
cidata := "cidata.iso"
ssh-key-file := base / "id_ed25519"
ssh-pub-key-file := ssh-key-file+".pub"

default:
    @just --list

pull:
    test -f {{image}} || wcurl https://cloud-images.ubuntu.com/noble/current/{{image}}

validate:
    cloud-init schema --config-file user-data

disk: pull
    mkdir -p {{base}}
    test -f {{base}}/{{disk}} || qemu-img create \
      -b ../{{image}} \
      -f qcow2 \
      -F qcow2 \
      {{base}}/{{disk}} \
      15G

keygen:
    mkdir -p {{base}}
    test -f {{ssh-key-file}} || ssh-keygen \
      -q \
      -t ed25519 \
      -N "" \
      -f {{ssh-key-file}}

inject-key: keygen
    yq -yi '.ssh_authorized_keys = ["{{trim(read(ssh-pub-key-file))}}"]' user-data
    sed -i '1i#cloud-config' user-data

pack-config: inject-key validate
    mkdir -p {{base}}
    test -f {{base}}/{{cidata}} || genisoimage \
      -output {{base}}/{{cidata}} \
      -V cidata \
      -r \
      -J \
      user-data meta-data

quickemu: disk pack-config
    quickemu --vm machine.conf

ssh:
    ssh \
      -i {{ssh-key-file}} \
      -o "StrictHostKeyChecking=no" \
      ubuntu@localhost \
      -p 22220

purge:
    rm -rf {{base}} {{image}}

clean:
    rm -rf {{base}}

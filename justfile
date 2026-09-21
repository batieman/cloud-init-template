image := "noble-server-cloudimg-amd64.img"
base := "machine"
disk := "disk.qcow2"
cidata := "cidata.iso"

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

pack-config:
    test -f {{base}}/{{cidata}} || genisoimage \
      -output {{base}}/{{cidata}} \
      -V cidata \
      -r \
      -J \
      user-data meta-data

run: pack-config disk
    qemu-system-x86_64 \
      -machine accel=kvm:tcg \
      -m 512 \
      -nographic \
      -drive file={{base}}/{{disk}},format=qcow2 \
      -drive file={{base}}/{{cidata}},media=cdrom,readonly=on \
      -nic user

# Cannot be run as first boot
quickemu: pack-config disk
    quickemu --vm machine.conf

purge:
    rm -rf {{base}} {{image}}

clean:
    rm -rf {{base}}

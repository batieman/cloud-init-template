image := "noble-server-cloudimg-amd64.img"

default:
    @just --list

pull:
    test -f {{image}} || wcurl https://cloud-images.ubuntu.com/noble/current/{{image}}
    qemu-img resize {{image}} 20G

setup:
    mkdir -p share

validate:
    cloud-init schema --config-file user-data

run: setup pull
    qemu-system-x86_64                                                        \
      -net nic                                                                \
      -net user                                                               \
      -machine accel=kvm:tcg                                                  \
      -m 512                                                                  \
      -nographic                                                              \
      -hda {{image}}                                                          \
      -virtfs local,path=share,mount_tag=share0,security_model=none,id=share0 \
      -smbios type=1,serial=ds='nocloud;s=http://10.0.2.2:8000/'

run-gui: setup pull
    qemu-system-x86_64                                                        \
      -net nic                                                                \
      -net user                                                               \
      -machine accel=kvm:tcg                                                  \
      -m 4096                                                                 \
      -display gtk                                                            \
      -hda {{image}}                                                          \
      -virtfs local,path=share,mount_tag=share0,security_model=none,id=share0 \
      -smbios type=1,serial=ds='nocloud;s=http://10.0.2.2:8000/'

clean:
    rm -f {{image}}

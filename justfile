pull:
    test -f noble-server-cloudimg-amd64.img || wcurl https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
    qemu-img resize noble-server-cloudimg-amd64.img +20G

setup:
    mkdir -p share

run: setup pull
    qemu-system-x86_64                                                        \
      -net nic                                                                \
      -net user                                                               \
      -machine accel=kvm:tcg                                                  \
      -m 512                                                                  \
      -nographic                                                              \
      -hda noble-server-cloudimg-amd64.img                                    \
      -virtfs local,path=share,mount_tag=share0,security_model=none,id=share0 \
      -smbios type=1,serial=ds='nocloud;s=http://10.0.2.2:8000/'

run-gui: setup pull
    qemu-system-x86_64                                                        \
      -net nic                                                                \
      -net user                                                               \
      -machine accel=kvm:tcg                                                  \
      -m 4096                                                                 \
      -display gtk                                                            \
      -hda noble-server-cloudimg-amd64.img                                    \
      -virtfs local,path=share,mount_tag=share0,security_model=none,id=share0 \
      -smbios type=1,serial=ds='nocloud;s=http://10.0.2.2:8000/'

clean:
    rm noble-server-cloudimg-amd64.img

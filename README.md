### Usage
Install Direnv and Nix
``` sh
cd cloud-init-template
direnv allow
```
When booting the VM, Python3 is used to serve cloud-init files to the VM.
``` sh
http:start
```
Will start this server and VM will be launched in a new a terminal.
``` sh
just run
```
Use Ctrl-a x to quit the VM.

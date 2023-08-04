# How I set my computers up to run Virtual machines on Linux

1. Pick a Linux distribution that works for you, I am using Ubuntu
2. Install libvirtd
    sudo apt install libvirtd
    sudo systemctl enable libvirtd
    sudo systemctl start libvirtd
3. Install VMM (virtual machine manager)
    sudo apt install vmm
4. Connect VMM to your local machine under New Connection


Start building VMs with
[VMM](https://virt-manager.org/)
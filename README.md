# picoSH - Minimal PICO-8 OS for the ClockworkPi GameShell

picoSH is a minimal OS for the ClockworkPi GameShell designed to do one thing well: run your favorite PICO-8 carts.

## Dependencies

The picoSH build process depends Docker, and a couple other dependencies needed on the host system for builds:

- multistrap
- qemu-user-static

To make building picoSH easier you should use the included Vagrantfile.

## Including PICO-8 in the picoSH image

picoSH does not include a copy of PICO-8. To build picoSH place an unzipped copy of PICO-8 under `rootfs/home/picosh/pico-8`. The PICO-8 binary should reside at this path.

## Vagrant

picoSH can be built using Vagrant on the host system. Make sure Vagrant and VirtualBox are installed and simply run:

    vagrant up
    vagrant ssh

Once in the VM navigate to `/vagrant` and run:

    make build

## Connect to Wi-Fi

Run `connmanctl`:

    connmanctl> enable wifi
    connmanctl> scan wifi
    connmanctl> services
    connmanctl> agent on
    connmanctl> connect wifi_...
    connmanctl> quit

Wi-Fi should remain configured after reboot.

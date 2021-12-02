# iOS-Mount
Utility script to mount iOS photos and app files on linux, built around ifuse


### Features
 - Both CLI and GUI, automatically determined by how you launch it
 - Mount both common filesystem (which contains photos and other generic data) and individual app document folders
 - Fully interactive and very easy to use


### Install

#### Arch based
iOS-Mount is [available on the AUR](https://aur.archlinux.org/packages/ios-mount-git/)

Install it with an AUR helper (eg. [paru](https://github.com/Morganamilo/paru) or [yay](https://github.com/Jguer/yay)) or manually (`makepkg -si`)

#### Manual install
Close this repo, cd into it and install with make:

```bash
git clone https://github.com/Willy-JL/iOS-Mount
cd iOS-Mount
sudo make install
```


### Dependencies
- **bash**
- **ifuse**
- **zenity** (for GUI)

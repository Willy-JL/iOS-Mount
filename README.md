# iOS Mount
Utility script to mount iOS photos and app files on linux, built around ifuse

### Features
 - Both CLI and GUI, automatically determined by how you launch it
 - Mount both common filesystem (which contains photos and other generic data) and individual app document folders
 - Fully interactive and very easy to use

### Dependencies
- **ifuse**
- **libimobiledevice**
- **zenity** (for GUI)
- **xdg-open** (to launch a GUI file manager)

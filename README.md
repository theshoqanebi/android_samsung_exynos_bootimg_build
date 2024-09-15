# Boot Image Builder for Exynos850

This script automates the building and signing of boot images for the m12 device from kernel build output `arch/arm64/boot/Image` or ``arch/arm/boot/Image``.

## Features

- **Permissive & Enforcing Builds**: Toggle SELinux modes depending on your needs for testing or production.
- **Automated Signing**: Signs the boot image using a predefined RSA4096 key.
- **Clean Output Directory**: Provides an option to clean the build environment.

## Prerequisites

- **Python3**: Ensure Python3 is installed on your system.

## Usage
- **1. copy kernel (Image) from kernel build output to build folder**

- **2. Run the script**
```bash
./build_boot_image.sh [options]
```

### Options

This script supports several command-line options to customize the build process:
- `-d, --device [device_name]`: Specify the target device for the build. This allows the script to apply device-specific configurations or optimizations.
- `-p, --permissive`: Build the boot image with SELinux set to permissive. Use this mode if you need to debug the system with fewer restrictions.
- `-e, --enforcing`: Build the boot image with SELinux set to enforcing. This is the recommended mode for production environments to ensure security.
- `--clean`: Clean the output directory. Use this option to remove all files from the output directory without building a new boot image.
To use these options, append them to the script command when executing in the terminal.

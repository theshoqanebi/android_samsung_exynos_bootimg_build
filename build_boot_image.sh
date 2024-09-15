#!/bin/bash

# Define constants
base_dtb="build/dtb"
kernel="build/Image"
base_ramdisk="build/ramdisk"
device=""
image_name_prefix="boot"
base_cmdline="androidboot.hardware=exynos850 loop.max_part=7"
key_path="tools/avb/test/data/testkey_rsa4096.pem"
partition_size=46137344

# State of the build (default to enforcing)
permissive=false
clean_only=false

# Define Colors
green="\e[32m"
cyen="\e[36m"
red="\e[31m"
default="\e[0m"

# Function to update paths based on the selected device
update_paths() {
    dtb="${device}/$base_dtb"
    ramdisk="${device}/$base_ramdisk"
    image_name="out/${image_name_prefix}-${device}-$(date +%Y%m%d).img"
}

# Function to check required files
check_files() {
    if [[ ! -e "$kernel" ]]; then
        echo -e "$red[*] error: Kernel not exist$default"
        exit 1
    fi
    if [[ ! -e "$dtb" ]]; then
        echo "$red[*] error: dtb not exist$default"
        exit 1
    fi
    if [[ ! -e "$ramdisk" ]]; then
        echo "$red[*] error: ramdisk not exist$default"
        exit 1
    fi
}

# Build function
build() {
    echo -e "$cyen[*] Build started$default"

    # Set cmdline and board based on build mode and device
    if $permissive; then
        echo -e "$cyen[*] Permissive Build$default"
        cmdline="$base_cmdline androidboot.selinux=permissive"
    else
        echo -e "$cyen[*] Enforcing Build$default"
        cmdline="$base_cmdline androidboot.selinux=enforce"
    fi

    # Adjust board based on device
    if [ "$device" = "m12" ]; then
    	board="SRPTJ05C005"
    elif [ "$device" = "a12" ]; then
        board="SRPUE06B012"
    elif [ "$device" = "f12" ]; then
	board="SRPTJ12B008"
    elif [ "$device" = "a21s" ]; then
	board="SRPTA21C012"
    elif [ "$device" = "m13" ]; then
	board="SRPVA26A006"
    elif [ "$device" = "a13" ]; then
	board="SRPUK09B008"
    elif [ "$device" = "f13" ]; then
	board="SRPVC03A006"
    fi

    # Set OS version based on device
    os_version="13.0.0"
    case $device in
        m13|a13|f13)
            os_version="14.0.0"
            ;;
    esac

    mkdir -p out
    python3 tools/mkbootimg/mkbootimg.py --header_version 2 --os_version "$os_version" --os_patch_level 2023-06 \
        --kernel "$kernel" --ramdisk "$ramdisk" --dtb "$dtb" \
        --pagesize 0x00000800 --base 0x00000000 --kernel_offset 0x10008000 \
        --ramdisk_offset 0x11000000 --second_offset 0x00000000 \
        --tags_offset 0x10000100 --dtb_offset 0x0000000010000000 \
        --board "$board" --cmdline "$cmdline" --output "$image_name"

    echo -e "$cyen[*] Signing Image$default"
    python3 tools/avb/avbtool.py add_hash_footer --image "$image_name" \
        --partition_name boot --partition_size $partition_size \
        --key "$key_path" --algorithm SHA256_RSA4096

    echo -e "$green[✓] Done$default"
}

# Clean function
clean() {
    rm -rf out
    echo -e "$green[✓] Cleaned output directory$default"
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--permissive) permissive=true ;;
        -e|--enforcing) permissive=false ;;
        --clean) clean_only=true ;;
        -d|--device) shift; device=$1; update_paths ;;
        *) echo -e "$red[*] Unknown parameter passed: $1 $default"; exit 1 ;;
    esac
    shift
done

# Check if device is set
if [ -z "$device" ]; then
    echo -e "$red[*] You must specify a device with -d or --device$default"
    exit 1
fi

# Main logic
if $clean_only; then
    clean
else
    check_files
    build
fi

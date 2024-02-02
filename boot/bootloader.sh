#!/bin/bash

# Script to easier boot linux kernels from any kinds of media


# TODO some distros don't have an initrd
# TODO load config from file
# TODO load config from grub

# build string like 'kexec -l kernel-image --append=command-line-options --initrd=initrd-image'
function build_kexec_array() {
    kexec_array=()
    if [ -z "$commandline" ]
    then
        # commandline empty
        kexec_array=( kexec -l "${path_to_vmlinuz}" --initrd="${path_to_initrd}" )
    else
        # commandline provided
        if [ "$commandline" == "reuse" ]
        then
            kexec_array=( kexec -l "${path_to_vmlinuz}" --initrd="${path_to_initrd}" --reuse-cmdline)
        else
            kexec_array=( kexec -l "${path_to_vmlinuz}" --append="\"${commandline} rootdelay=60 rootwait\"" --initrd="${path_to_initrd}" )
        fi
    fi

}

# select if we want to reuse, type in or skip the commandline
function select_commandline() {
    choice=$(dialog --clear \
        --cancel-label "Skip" \
        --ok-label "OK" \
        --menu "Select commandline:" 12 40 3 \
        1 "Reuse" \
        2 "Auto set root" \
        3 "Live disk / casper boot" \
        4 "Type in" \
        5 "None/Skip"\
    3>&1 1>&2 2>&3)

    # check exit code to determine which button was pressed
    case $choice in
        1) commandline="reuse";;
        2) get_root;;
        3) get_commandline_casper;;
        4) get_custom_commandline;;
        *) ;; # don't do anything
    esac
}

# build a commandline string for casper based boot-disks
function get_commandline_casper(){
    get_root
    commandline="boot=casper ${commandline} video=vesafb intel_idle.max_cstate=1 processor.max_cstate=2 nohpet"
}

# detect disk the kernel has been found on to use as root
function get_root(){
    root_name="${path_to_vmlinuz#/root/atv-mnt/}"   # Remove "/root/atv-mnt/" from the beginning
    root_name="${root_name%%/*}"          # Extract everything before the first "/"
    commandline="root=/dev/${root_name}"
}

# type in kernel commandline
function get_custom_commandline() {
    commandline=$(\
  dialog --title "Kernel Commandline" \
         --ok-label "OK" --cancel-label "Skip" \
         --inputbox "Enter the command:" 8 40 \
  3>&1 1>&2 2>&3 3>&- \
  )
}

# search for an initrd
function find_initrd_files() {
    # Specify the target directory to search
    target_directory="/"

    # Find all initrd files and store in the initrd_array
    initrd_array=($(find "$target_directory" -type f \( -name "initrd*" -o -name "initram*" -o -name "initrfs*" \) 2>/dev/null))

}

# search for a linux kernel
function find_kernel_files() {
    # Specify the target directory to search
    target_directory="/"

    # Find all vmlinuz files and store in the vmlinuz_array
    vmlinuz_array=($(find "$target_directory" -type f \( -name "vmlinuz*" -o -name "kernel" -o -name "linux" \) 2>/dev/null))
}

# select how we want to boot (not in use right now)
function select_options() {
    choice=$(dialog --clear --nocancel --title "Commandline" \
        --ok-label "OK" \
        --menu "Select commandline:" 10 40 3 \
        1 "Manual" \
        2 "Load from savefile" \
        3 "Load from grub"\
    3>&1 1>&2 2>&3)

    echo $choice

    # check the exit code to determine which button was pressed
    case $choice in
        1) display_menu_list;;
        *) ;; # don't do anything
    esac
}

# takes array of strings and displays a selectable list
# used for selection of initrd and kernel paths
function display_menu_list() {
    list=("$@")
    declare -a dia=()  # dialog array

    for index in "${!list[@]}"; do # for each index in the list
    dia+=("$index" "${list[index]}")
    done

    choice=$(dialog --menu "$menu_list_title" 0 0 0 "${dia[@]}" \
        3>&1 1>&2 2>&3)
    dialog_rc=$? # Save the dialog return code

    clear # restore terminal background and clear

    case $dialog_rc in
        1)
            echo 'Cancelled menu'
            exit 1
            ;;
        255)
            echo 'Closed menu without choice'
            exit 1
            ;;
        *) ;; # don't do anything
    esac
    selected_menu_entry="${list[choice]}"
}

# Main menu using dialog
# connect stdin/stdout/stderr to the current console
exec < /dev/tty0
exec 1> /dev/tty0
exec 2> /dev/tty0

find_kernel_files

find_initrd_files

menu_list_title="Select Linux Kernel"
display_menu_list "${vmlinuz_array[@]}"

path_to_vmlinuz=$selected_menu_entry

menu_list_title="Select Linux Initrd"
display_menu_list "${initrd_array[@]}"

path_to_initrd=$selected_menu_entry

select_commandline

#if [ -z "$commandline" ]
#then
#      echo "\$commandline is empty"
#else
      #echo "\$commandline is NOT empty"
      #echo "$commandline"
#fi

# build kexec string
build_kexec_array

#echo "${kexec_array[@]}"
"${kexec_array[@]}"
# save config?

# sleep 45

# boot
kexec -e


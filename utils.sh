#!/bin/bash

source $(dirname $(realpath $0))/bash_formatting.sh
real_pwd=$(dirname $(realpath "$0"))

help()
{
    echo -e "${bold}${yellow}Description:${reset} My custom utilities"
    echo -e "${bold}${yellow}Usage:${reset} $(basename "$0") OPTION [PARAMS]"
    echo -e ""
    echo -e "${magenta}-h -help${reset}"
    echo -e "       Print this help message"
    echo -e "${magenta}-r -restart-plasma${reset}"
    echo -e "       Restart KDE Plasma desktop"
    echo -e "${magenta}-m -set-monitors${reset}"
    echo -e "       Set the monitors to my default configuration"
    echo -e "${magenta}-s -switch-primary${reset}"
    echo -e "       Switch the primary monitor"
    echo -e "${magenta}-w -wait-internet${reset} [verbose]"
    echo -e "       Notify me on internet status [print 'no internet']"
    echo -e "${magenta}-p -pid-command${reset} <pid(s)> <command>"
    echo -e "       Run a command after a process exits"
    echo -e "${magenta}-d -davinci-convert${reset} <file> [audio|video]"
    echo -e "       Extract audio to MP3 OR convert Resolve output to MP4 [specify output]"
    echo -e "${magenta}-u -update-system${reset} [mirror]"
    echo -e "       yay -Syyu & bypass 'sudo session' timeout [update mirror list]"
    echo -e "${magenta}-y -yay${reset}"
    echo -e "       Bypass 'sudo session' timeout for yay - takes its args"
    echo -e "${magenta}-n -update-notes${reset}"
    echo -e "       Backup my notes to GitHub"
    echo -e "${magenta}-e -repair-ep${reset} [mac address]"
    echo -e "       Unpair and repair bluetooth device"
    echo -e "${magenta}-em -ep-mode${reset} [card name]"
    echo -e "       Switch audio profiles of bluetooth earphones"
    echo -e "${magenta}-mirrors${reset}"
    echo -e "       Update pacman mirror list"
    echo -e "${magenta}-sudo-timout${reset} <program>"
    echo -e "       Bypass 'sudo session' timeout on specific program"    
    echo -e "${magenta}-start-qemu-vm${reset} <vm name>"
    echo -e "       Start a QEMU virtual machine"
    echo -e "${magenta}-update-walc${reset} <version> <commit msg>"
    echo -e "       Update the 'WALC' AUR package"
    echo -e "${magenta}-update-setcustomres${reset} <version> <commit msg>"
    echo -e "       Update the 'setcustomres' AUR package"
    echo -e "${magenta}-update-salawat${reset} <version> <commit msg>"
    echo -e "       Update the 'salawat' AUR package"
}

ns()
{
    notify-send -u critical -i "emblem-rabbitvcs-normal" -a "Utils" "$@"
}

print_message() 
{
    echo -e "\n    ${blue}[+]${reset}${bold} $1${reset} \n"
}

print_warning()
{    
    echo -e "\n    ${yellow}[+]${reset}${bold} $1${reset} \n"
}

print_error()
{
    echo -e "${red}ERROR:${reset} ${bold}$1${reset}"
    [[ "$2" != "no_exit" ]] && exit 1
}

get_monitor_names()
{
    graphics_mode="$(optimus-manager --print-mode | cut -d " " -f5)"
    if [[ $graphics_mode = "nvidia" ]]; then
        laptop_output="eDP-1-1"
        secondary_output="DP-1-1"
    else
        laptop_output="eDP-1"
        secondary_output="DP-1"
    fi

    primary_output="$(xrandr | grep 'primary' | cut -d ' ' -f1)"

    if [[ "$1" = "laptop" ]]; then
        echo "$laptop_output"
    elif [[ "$1" = "secondary" ]]; then
        echo "$secondary_output"
    elif [[ "$1" = "primary" ]]; then
        echo "$primary_output"
    else
        print_error "Invalid input ${1}! - Provide 'laptop' or 'secondary'" "no_exit"
    fi
}

restart_plasma()
{
    print_message "Restarting Plasma Desktop"
    kquitapp5 plasmashell
    kstart5 plasmashell&
}

start_qemu_vm()
{
    print_message "Starting VM: $1"
    virsh --connect qemu:///system start "$1"
    virt-manager --connect qemu:///system --show-domain-console "$1"
}

switch_primary_monitor()
{
    laptop_output=$(get_monitor_names laptop)
    secondary_output=$(get_monitor_names secondary)
    primary_output=$(get_monitor_names primary)

    if [[ $laptop_output = "$primary_output" ]]; then
        xrandr --output $secondary_output --primary
    else
        xrandr --output $laptop_output --primary
    fi
}

# OBSOLETE - REPLACED WITH `setcustomres` (https://github.com/MisconceivedSec/setcustomres)
#
# setCustomRes()
# {
#     print_message "Setting custom resolution of $1x$2 to output $3 $([[ "$4" ]] && echo "with flags: $4")"
#     printMessage "Setting custom resolution of $1x$2 to output $3 $([[ "$4" ]] && echo "with flags: $4")"
#     print_message "Setting custom resolution of $1x$2 to output $3 $([[ "$4" ]] && echo "with flags: $4")"
#     print_message "Setting custom resolution of $1x$2 to output $3 $([[ "$4" ]] && echo "with flags: $4")"
#     h=$1
#     v=$2
#     res="$1x$2"
#     output=$3
#     flags=$4
    
#     cvt=$(echo $res $(cvt "$h" "$v" | tail -1 | cut -d ' ' -f3-))
#     mode=$(echo $cvt | cut -d ' ' -f1)
#     status=checkMonitorStatus $output $res

#     monitor_connected=$(xrandr --listactivemonitors | grep " $output")

#     if [[ $monitor_connected = "" ]]; then
#         echo "${red}ERROR:${reset} Monitor is not active!"
#         exit 1
#     fi

#     if [[ $status = "false" ]]; then
#         xrandr --newmode $(echo $cvt)
#         xrandr --addmode "$output" "$mode"
#     fi
    
#     xrandr --output "$output" --mode "$mode" $(echo $flags)
# }
# checkMonitorStatus()
# {
#     output="$1"
#     mode="$2"

#     monitor_set="false"
#     reached_output="false"
#     number='^[0-9]+$'

#     while read -r line
#     do
#         if [[ $(echo "$line" | awk '{print $1}') = "$output" ]]; then
#             reached_output="true"
#         elif [[ $reached_output = "true" ]] && [[ $(echo "$line" | cut -d 'x' -f1) =~ $number ]]; then
#             [[ $(echo $line | awk '{print $1}') = "$mode" ]] && monitor_set="true"
#         elif ! [[ $(echo "$line" | cut -d ' ' -f1) = "" ]]; then
#             reached_output="false"
#         fi
#     done < <(xrandr)

#     echo $monitor_set
# }

set_monitors()
{
    laptop_output=$(get_monitor_names laptop)
    secondary_output=$(get_monitor_names secondary)
    
    xrandr --output $laptop_output --auto 2> /dev/null
    xrandr --output $secondary_output --auto 2> /dev/null # Switch monitor on if it is switched off
    setcustomres -w 1600 -h 900 -o $laptop_output # Primary Screen
    setcustomres -w 1920 -h 1080 -o $secondary_output -p "--right-of $laptop_output" # Secondary Screen
    
    # ##### Primary Screen #####
    
    # primary_mode="1600x900"
    # primary_set="$(python3 "$real_pwd/display_check.py" $laptop_output $primary_mode)"
    # primary_cvt=$(echo "$primary_mode  $(cvt 1600 900 | tail -1 | cut -d ' ' -f3-)")
    
    # [[ $primary_set = "False" ]] && xrandr --newmode $(echo $primary_cvt); xrandr --addmode $laptop_output $primary_mode
    # xrandr --output $laptop_output --mode $primary_mode
    
    # ##### External Monitor #####

    # secondary_mode="1920x1080"
    # secondary_set="$(python3 "$real_pwd/display_check.py" $secondary_output $secondary_mode)"
    # secondary_connected=$(xrandr --listactivemonitors | grep " $secondary_output")
    
    # if [[ $secondary_connected != "" ]]; then
    #     secondary_cvt=$(echo "$secondary_mode  $(cvt 1920 1080 | tail -1 | cut -d ' ' -f3-)")
    #     [[ $secondary_set = "False" ]] && xrandr --newmode $(echo $secondary_cvt); xrandr --addmode $secondary_output $secondary_mode
    #     xrandr --output $secondary_output --mode $secondary_mode --right-of $laptop_output
    # fi

}

run_after_pid()
{
    pid=$1
    shift
    command="$@"

    print_message "Will run command ($command) after pid $pid exits"
    while [[ $(ps "$pid" &> /dev/null)$? -eq 0 ]]; do
        sleep 2
    done && $command
}

update_setcustomres()
{
    real_pwd=$PWD
    version=$1
    commit_message=$2

    cd /home/abdullah/01-Projects/GH/aur/

    print_message "SETCUSTOMRES PKGBUILD UPDATER"

    sleep 0.5
    print_message "Downloading source file..."
    wget -nc "https://github.com/MisconceivedSec/setcustomres/archive/refs/tags/v${version}.tar.gz"
    file=v${version}.tar.gz

    sleep 0.5
    print_message "Generating MD5 sum..."
    md5sum=$(md5sum "$file" | awk '{print $1;}')

    sleep 0.5
    print_message "Updating PKGBUILD"
    cat SETCUSTOMRES_PKGBUILD_TEMPLATE | sed -e "s/put_version_number_over_here/$version/" -e "s/some-long-md5-hash/$md5sum/" > setcustomres/PKGBUILD
    cd setcustomres
    makepkg --printsrcinfo > .SRCINFO

    print_message "Committing Changes"
    git add PKGBUILD .SRCINFO
    git commit -m "$commit_message"

    print_message "Pushing Changes"
    git push

    print_message "All done!"
    rm -f $file
    cd $real_pwd
}

update_walc()
{
    real_pwd=$PWD
    version=$1
    commit_message=$2

    cd /home/abdullah/01-Projects/GH/aur/

    print_message "WALC PKGBUILD UPDATER"
    sleep 0.5
    print_message "Downloading source file..."

    wget -nc "https://github.com/WAClient/WALC/archive/refs/tags/v${version}.tar.gz"
    file=v${version}.tar.gz

    sleep 0.5
    print_message "Generating MD5 sum..."
    md5sum=$(md5sum "$file" | awk '{print $1;}')

    sleep 0.5
    print_message "Updating PKGBUILD"
    cat WALC_PKGBUILD_TEMPLATE | sed -e "s/put_version_number_over_here/$version/" -e "s/some-long-md5-hash/$md5sum/" > walc/PKGBUILD
    cd walc
    makepkg --printsrcinfo > .SRCINFO

    print_message "Committing Changes"
    git add PKGBUILD .SRCINFO
    git commit -m "$commit_message"

    print_message "Pushing Changes"
    git push

    print_message "All done!"
    rm -f $file
    cd $real_pwd
}

update_salawat()
{
    real_pwd=$PWD
    version=$1
    commit_message=$2

    cd /home/abdullah/01-Projects/GH/aur/

    print_message "SALAWAT PKGBUILD UPDATER"
    sleep 0.5
    print_message "Downloading source file..."

    wget -nc "https://github.com/DBChoco/Salawat/releases/download/v${version}/Salawat-${version}-linux.tar.gz"
    file=Salawat-${version}-linux.tar.gz

    sleep 0.5
    print_message "Generating MD5 sum..."
    md5sum=$(md5sum "$file" | awk '{print $1;}')

    sleep 0.5
    print_message "Updating PKGBUILD"
    cat SALAWAT_PKGBUILD_TEMPLATE | sed -e "s/put_version_number_over_here/$version/" -e "s/some-long-md5-hash/$md5sum/" > salawat/PKGBUILD
    cd salawat
    makepkg --printsrcinfo > .SRCINFO

    print_message "Committing Changes"
    git add PKGBUILD .SRCINFO
    git commit -m "$commit_message"

    print_message "Pushing Changes"
    git push

    print_message "All done!"
    rm -f $file
    cd $real_pwd
}

davinci_convert()
{
    inputfile=$1
    action=$2

    if [[ $(echo $inputfile | cut -d '.' -f 2) = "mp4" || "$action" = "audio" ]]; then
        outputfile="$(echo $inputfile | cut -d '.' -f 1).mp3"

        print_message "Extracting audio out of '$inputfile'"

        ffmpeg -i "$inputfile" "$outputfile" && ns "Audio extraction completed" "Extracted $outputfile from $inputfile"

        print_message "Audio extraction of '$inputfile' completed"
    elif [[ ! $(echo $inputfile | cut -d '.' -f 2) = "mp4" || "$action" = "video" ]]; then
        outputfile="$(echo $inputfile | cut -d '.' -f 1).mp4"

        print_message "Converting '$inputfile' into '$outputfile'"

        ffmpeg -i "$inputfile" -ac 2 "$outputfile"
        print_message "Converted '$inputfile' into '$outputfile'"
        
        # del=$()  "Would you like to delete ${inputfile}?"  -A "del"="Delete Permanently" 
        ns "Converted '$inputfile' to '$outputfile'"-i "emblem-rabbitvcs-modified" 
        # if [[ $del ]]; then
        #     rm -f "$inputfile"
        #     print_warning "Deleted '$inputfile'"
        # fi
    fi
}

repair_ep() {
    if [[ $1 ]]; then
        mac=$1
    else
        mac='A4:77:58:51:59:6C'
    fi

    print_message "Re-paring device '$mac'"

    bluetoothctl remove $mac
    bluetoothctl --timeout 5 scan on
    bluetoothctl pair $mac
    bluetoothctl connect $mac && ns "Reconnected to $mac"
}

wait_internet()
{
    if [[ "$1" = "v" ]]; then
        print_message "Checking internet status (will print errors)"
    else
        print_message "Checking internet status"
    fi

    server="1.1.1.1"
    
    while true; do
        _ping=$(ping $server -c 1 2> /dev/null)
        dns_latency=$(echo "$_ping" | sed -n -e 2p | cut -d ' ' -f 7 | cut -d '=' -f 2)
        rounded_latency=$(echo $dns_latency | cut -d '.' -f 1)

        if [[ "$_ping" = *"100% packet loss"* || ! "$_ping" ]]; then
            [[ "$1" = "v" ]] && print_error "DNS Unreachable (No Internet)" no_exit
	        sleep 30
        elif [[ "$rounded_latency" -ge "400" ]]; then
            print_warning "Internet is accessible, but slow (Latency: ${dns_latency}ms)"
            ns "Internet is slow" "Latency: ${dns_latency}" -i "emblem-rabbitvcs-modified"
            exit
        elif [[ "$rounded_latency" -le "400" ]]; then
            print_message "Connected to the internet! (Latency: ${dns_latency}ms)"
            ns "Connected to the internet!" "Latency: ${dns_latency}ms"
            exit
        fi
    done
}

sudo_timeout()
{

    program=$1
    [[ "$2" ]] && _sleep=$2 || _sleep=30
    
    print_message "Disabling sudo timeout while $program is running"

    sudo -v &> /dev/null

    {
        sleep $_sleep
        while true; do
            if [[ $(pidof $program) ]] ; then
                sudo -v &> /dev/null
                sleep 30
            else
                # ns "$program exited"
                exit
            fi
        done
    } & disown
}

update_mirrors() {
    print_message "Updating mirror list to the fastest 5"
    sudo pacman-mirrors --fasttrack 5
}

_yay() {
    sudo_timeout yay

    print_message "Running yay $*"
    yay "$@"
}

update_system() {
    
    mirror=$1

    if [[ $mirror ]]; then
        update_mirrors
    fi

    print_message "Updating system with 'yay'"

    _yay -Syyu --noconfirm && ns "System Update Completed Successfully"
}

update_notes() {
    _pwd="$(pwd)"
    cd "/home/abdullah/01-Projects/My-Notes"
    { git add -u && git add ./*
    git commit -m "Auto Update: $(TZ='UTC' date)"
    git push; } |& tee "./.logs/Update at ($(date +%a\ %e\ %b\ %I:%M:%S)).log"
    ns "Notes Auto Update" "\n\nUpdated notes at $(TZ='UTC' date)" --app-name="Utils" -t 15000 -u normal
    cd $_pwd
}

ep_mode() {
    if [[ $1 ]]; then
        card=$1
    else
        card='bluez_card.A4_77_58_51_59_6C'
    fi

    # a2dp_sink
    # handsfree_head_unit
    # pacmd set-card-profile CARD PROFILE

    if [[ $(pacmd list-sinks | grep $card -A 3) = *"a2dp_sink"* ]]; then
        print_message "Switching profile of '$card' to 'handsfree_head_unit'"
        pacmd set-card-profile $card handsfree_head_unit
    else
        print_message "Switching profile of '$card' to 'a2dp_sink'"
        pacmd set-card-profile $card a2dp_sink
    fi
}

flags() {

    if [[ "$#" -eq 0 ]]; then
        print_error "Missing arguments, parse \"-help\" for more information"
    fi    
    
    case $1 in
        -h|-help)
            help
            exit
            ;;
        -s|-switch-primary)
            switch_primary_monitor
            ;;
        -start-qemu-vm)
            if [ "$2" ]; then
                shift
                start_qemu_vm "$1"
            else
                print_error "\"-start-qemu-vm\" requires a non-empty argument"
            fi
            ;;
        -r|-restart-plasma)
            restart_plasma
            ;;
        -m|-set-monitors)
            set_monitors
            ;;
        -n|-update-notes)
            update_notes
            ;;
        -e|-repair-ep)
            if [[ $2 != -?* ]]; then
                shift
                repair_ep $1
            else
                repair_ep
            fi
            ;;
        -em|-ep-mode)
            if [[ $2 != -?* ]]; then
                shift
                ep_mode $1
            else
                ep_mode
            fi
            ;;
        -w|-wait-internet)
            if [[ "$2" = "verbose" ]]; then
                shift
                wait_internet v
            else
                wait_internet
            fi
            ;;
        -p|-pid-command)
            if [ "$2" ] && [ "$3" ]; then
                shift
                PID="$1"

                if ! ps -p "$PID" &> /dev/null; then
                    print_error "Provided PID does not exist!"
                fi

                shift
                COMMAND="$*"

                run_after_pid "$PID" "$COMMAND"
            else
                print_error "\"-s|-pid-command\" requires 2 non-empty arguments"
            fi
            ;;
        -update-walc)
            if [ "$2" ] && [ "$3" ]; then
                shift
                update_walc "$1" "$2"
            else
                print_error "\"-update-walc\" requires 2 arguments"
            fi
            ;;
        -update-setcustomres)
            if [ "$2" ] && [ "$3" ]; then
                shift
                update_setcustomres "$1" "$2"
            else
                print_error "\"-update-setcustomres\" requires 2 arguments"
            fi
            ;;
        -update-salawat)
            if [ "$2" ] && [ "$3" ]; then
                shift
                update_salawat "$1" "$2"
            else
                print_error "\"-update-salawat\" requires 2 arguments"
            fi
            ;;
        -d|-davinci-convert)
            if [ "$2" ]; then
                shift
                davinci_convert "$1" "$2"
            else
                print_error "\"-d|-convert-davinci-output\" requires a non-empty argument"
            fi
            ;;
        -u|-update-system)
            update_system "$2"
            if [[ "$2" && "$2" = "mirror" ]]; then
                shift
            elif [[ "$2" && ! "$2" = "mirror" ]]; then
                print_error "\"-u|-udpate-system\" takes 1 optional argument: 'mirror'"
            fi
            ;;
        -y|-yay)
            shift
            _yay "$@"
        ;;
        -mirrors)
            update_mirrors
        ;;
        -sudo-timeout)
            if [ "$2" ]; then
                shift
                sudo_timeout "$1"
            else
                print_error "\"-sudo-timeout\" requires a non-empty argument"
            fi
            ;;
        -?*)
            print_error "Unknown option: $1" no_exit
            help
            ;;
        *)       
            help
    esac
    shift
}

flags "$@"


# Might use this one day:
# --file=?*)
    #     file=${1#*=} # Delete everything up to "=" and assign the remainder.
    #     ;;
# -v|--verbose)
#             verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
#             ;;

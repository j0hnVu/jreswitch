#!/bin/bash

# Function to update the JAVA_HOME and JAVA_PATH in the profile
update_profile() {
    profile_file="$1"
    java_path="$2"
    java_home="$3"

    # Remove any existing JAVA_HOME entries
    sed -i '/^export JAVA_HOME=/d' "$profile_file" 
    sed -i '/jreswitcher[[:space:]]*\/[[:space:]]*java[[:space:]]*\/[[:space:]]*jre/d' "$profile_file"
    sed -i '/^export PATH=/d' "$profile_file" 
	
    # Add new JAVA_HOME and JAVA_PATH to the profile
    echo "export PATH=$java_path:\$PATH" >> "$profile_file"
    echo "export JAVA_HOME=$java_home" >> "$profile_file"
}

get_latest_jar_url() {
    jre_ver="$1"

    # x64 instead of x86_64 cause of Adoptium file naming
    if [ "$(uname -m)" = "x86_64" ]; then
        arch="x64"
    elif [ "$(uname -m)" = "armv7l" ]; then
        arch="arm"
    else
        arch="$2"
    fi

    # Check for OS distribution
    if grep -iq "alpine" /etc/os-release; then
        dist_suffix="_alpine-linux_"
    else
        dist_suffix="_linux_"
    fi

    curl -s "https://api.github.com/repos/adoptium/temurin${jre_ver}-binaries/releases/latest" | jq -r --arg arch "$arch" --arg suffix "$dist_suffix" '.assets[] | select(.name | contains("hotspot") and contains("jre") and contains($arch) and contains($suffix) and endswith(".tar.gz")) | .browser_download_url'
}

installer(){
    jre_ver="$1"
    if [ ! -d $dir_path/jre${jre_ver} ]; then
        mkdir -p $dir_path/jre${jre_ver}
    fi
    cd $dir_path/jre${jre_ver}
    wget -q --show-progress "$(get_latest_jar_url "$jre_ver" "$(uname -m)")" || { echo "Download failed. Network issue or URL is expired.";sleep 5; exit 1; }
    tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
    java_path=$(readlink -f $dir_path/jre${jre_ver}/bin)
    java_home=$(readlink -f $dir_path/jre${jre_ver})
}

# Required dependencies
#sudo apt update
#sudo apt install wget tar jg
clear

# Create the jreswitcher directories if they don't exist
mkdir -p ~/jreswitcher/java
echo "Current architecture: $(uname -m)"
echo "Please choose a Java Runtime version: "
printf "\n"
echo "1. JRE 8"
echo "2. JRE 17"
echo "3. JRE 18"
echo "4. JRE 21"
echo "5. JRE 22"
echo "6. JRE 23"
# echo "o. Override architecture" {TODO}
echo "p. Delete all downloaded JRE"
echo "0. Exit"
read -p "Option: " option

clear

# Define profile file and JRE directory path for the script (Debian uses .profile for login shells)
profile_file="$HOME/.profile"
dir_path="$HOME/jreswitcher/java"

case $option in
    1) # JRE8
        installer "8" ;;
    2) # JRE17
        installer "17" ;;
    3) # JRE 18
        installer "18" ;;
    4) # JRE 21
        installer "21" ;;
    5) # JRE 22
        installer "22" ;;
    6) # JRE 23
        installer "23" ;;
    #o) Override Architecture
    #    echo "TO-DO"
    #    ;;
    p)
        rm -rf $dir_path/*
        echo "All JREs deleted."
        exit 0
        ;;
    0)
        exit 0
        ;;
    *)
        echo "Invalid option. Script is terminated"
        exit 1
        ;;
esac

# Update the JAVA_PATH and JAVA_HOME in the profile file
update_profile "$profile_file" "$java_path" "$java_home"
# Reload the profile to apply the changes
source "$profile_file"

clear
java -version

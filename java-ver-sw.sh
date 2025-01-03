#!/bin/bash

# Function to update the JAVA_HOME and JAVA_PATH in the profile
update_profile() {
    profile_file="$1"
    java_path="$2"
    java_home="$3"

    # Remove any existing JAVA_HOME entries
    sed -i '/^export JAVA_HOME=/d' "$profile_file" 

    # Remove any existing PATH settings related to jdkswitcher
    sed -i '/jdkswitcher[[:space:]]*\/[[:space:]]*java[[:space:]]*\/[[:space:]]*jdk/d' "$profile_file"

    # Remove all existing PATH assignments (if there are multiple)
    sed -i '/^export PATH=/d' "$profile_file" 
	
	
	if [[ ":$PATH:" != *":$java_path:"* ]]; then
        # Remove any existing jdkswitcher paths from current PATH
        export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "jdkswitcher" | tr '\n' ':' | sed 's/:$//')

        # Add new JAVA_HOME and JAVA_PATH to the profile
        echo "export PATH=$java_path:\$PATH" >> "$profile_file"
        echo "export JAVA_HOME=$java_home" >> "$profile_file"
    else
        echo "The path $java_path is already in PATH, skipping update."
    fi
}

# Required.
sudo apt install wget tar

# Create the jdkswitcher directories if they don't exist
mkdir -p ~/jdkswitcher/java >> /dev/null
echo "Which Java version?"
printf "\n"
echo "1. jdk8"
echo "2. jdk17"
echo "3. jdk18"
echo "4. jdk21"
echo "5. jdk22"
echo "6. jdk23"
echo "p. Delete all downloaded JDK"
echo "0. Exit"
printf "\n"
printf "Option: "
read option

clear

# Define profile file and JDK directory path for the script (Debian uses .profile for login shells)
profile_file="$HOME/.profile"
dir_path="~/jdkswitcher/java"

case $option in
    1) # JDK8
        if [ ! -d $dir_path/jdk8 ]; then
            mkdir -p $dir_path/jdk8
            cd $dir_path/jdk8
            wget -q --show-progress "https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u422-b05/openlogic-openjdk-8u422-b05-linux-x64.tar.gz"
            tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
        fi
        java_path=$(readlink -f $dir_path/jdk8/bin)
        java_home=$(readlink -f $dir_path/jdk8)
        ;;
    2) # JDK17
        if [ ! -d $dir_path/jdk17 ]; then
            mkdir -p $dir_path/jdk17
            cd $dir_path/jdk17
            wget -q --show-progress "https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz"
            tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
        fi
        java_path=$(readlink -f $dir_path/jdk17/bin)
        java_home=$(readlink -f $dir_path/jdk17)
        ;;
    3) # JDK 18
        if [ ! -d $dir_path/jdk18 ]; then
            mkdir -p $dir_path/jdk18
            cd $dir_path/jdk18
            wget -q --show-progress "https://download.java.net/java/GA/jdk18/43f95e8614114aeaa8e8a5fcf20a682d/36/GPL/openjdk-18_linux-x64_bin.tar.gz"
            tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
        fi
        java_path=$(readlink -f $dir_path/jdk18/bin)
        java_home=$(readlink -f $dir_path/jdk18)
        ;;
    4) # JDK 21
        if [ ! -d $dir_path/jdk21 ]; then
            mkdir -p $dir_path/jdk21
            cd $dir_path/jdk21
            wget -q --show-progress "https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_linux-x64_bin.tar.gz"
            tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
        fi
        java_path=$(readlink -f $dir_path/jdk21/bin)
        java_home=$(readlink -f $dir_path/jdk21)
        ;;
    5) # JDK 22
        if [ ! -d $dir_path/jdk22 ]; then
            mkdir -p $dir_path/jdk22
            cd $dir_path/jdk22
            wget -q --show-progress "https://download.java.net/java/GA/jdk22/830ec9fcccef480bb3e73fb7ecafe059/36/GPL/openjdk-22_linux-x64_bin.tar.gz"
            tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
        fi
        java_path=$(readlink -f $dir_path/jdk22/bin)
        java_home=$(readlink -f $dir_path/jdk22)
        ;;
    6) # JDK 23
        if [ ! -d $dir_path/jdk23 ]; then
            mkdir -p $dir_path/jdk23
            cd $dir_path/jdk23
            wget -q --show-progress "https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-x64_bin.tar.gz"
            tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
        fi
        java_path=$(readlink -f $dir_path/jdk23/bin)
        java_home=$(readlink -f $dir_path/jdk23)
        ;;
    p)
        rm -rf $dir_path/*
        ;;
    0)
        exit 1
        ;;
    *)
        echo "Invalid option. Script is terminated"
        exit 1
        ;;
esac

# Update the JAVA_PATH and JAVA_HOME in the profile file
if [ "$option" != "p" ]; then
    update_profile "$profile_file" "$java_path" "$java_home"
fi

# Reload the profile to apply the changes only once
source "$profile_file"

clear
java -version

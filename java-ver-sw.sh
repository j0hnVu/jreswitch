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


# Create the jdkswitcher directories if they don't exist
mkdir -p ~/jdkswitcher/java
echo "Which Java version?"
printf "\n"
echo "1. jdk8"
echo "2. jdk17"
echo "3. jdk18"
echo "4. jdk21"
echo "5. jdk22"
printf "\n"
printf "Option: "
read option

clear

# Choose profile file based on the system (Debian typically uses .profile for login shells)
profile_file="$HOME/.profile"

# JDK 8
if [ "$option" = "1" ]; then
    if [ ! -d ~/jdkswitcher/java/jdk8/ ]; then
        mkdir -p ~/jdkswitcher/java/jdk8/
        cd ~/jdkswitcher/java/jdk8/
        wget "https://builds.openlogic.com/downloadJDK/openlogic-openjdk/8u422-b05/openlogic-openjdk-8u422-b05-linux-x64.tar.gz"
        tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
    else
        echo "JDK 8 already installed."
    fi
    java_path=$(readlink -f ~/jdkswitcher/java/jdk8/bin)
    java_home=$(readlink -f ~/jdkswitcher/java/jdk8)

# JDK 17
elif [ "$option" = "2" ]; then
    if [ ! -d ~/jdkswitcher/java/jdk17/ ]; then
        mkdir -p ~/jdkswitcher/java/jdk17/
        cd ~/jdkswitcher/java/jdk17/
        wget "https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz"
        tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
    else
        echo "JDK 17 already installed."
    fi
    java_path=$(readlink -f ~/jdkswitcher/java/jdk17/bin)
    java_home=$(readlink -f ~/jdkswitcher/java/jdk17)

# JDK 18
elif [ "$option" = "3" ]; then
    if [ ! -d ~/jdkswitcher/java/jdk18/ ]; then
        mkdir -p ~/jdkswitcher/java/jdk18/
        cd ~/jdkswitcher/java/jdk18/
        wget "https://download.java.net/java/GA/jdk18/43f95e8614114aeaa8e8a5fcf20a682d/36/GPL/openjdk-18_linux-x64_bin.tar.gz"
        tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
    else
        echo "JDK 18 already installed."
    fi
    java_path=$(readlink -f ~/jdkswitcher/java/jdk18/bin)
    java_home=$(readlink -f ~/jdkswitcher/java/jdk18)

# JDK 21
elif [ "$option" = "4" ]; then
    if [ ! -d ~/jdkswitcher/java/jdk21/ ]; then
        mkdir -p ~/jdkswitcher/java/jdk21/
        cd ~/jdkswitcher/java/jdk21/
        wget "https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_linux-x64_bin.tar.gz"
        tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
    else
        echo "JDK 21 already installed."
    fi
    java_path=$(readlink -f ~/jdkswitcher/java/jdk21/bin)
    java_home=$(readlink -f ~/jdkswitcher/java/jdk21)

# JDK 22
elif [ "$option" = "5" ]; then
    if [ ! -d ~/jdkswitcher/java/jdk22/ ]; then
        mkdir -p ~/jdkswitcher/java/jdk22/
        cd ~/jdkswitcher/java/jdk22/
        wget "https://download.java.net/java/GA/jdk22/830ec9fcccef480bb3e73fb7ecafe059/36/GPL/openjdk-22_linux-x64_bin.tar.gz"
        tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
    else
        echo "JDK 22 already installed."
    fi
    java_path=$(readlink -f ~/jdkswitcher/java/jdk22/bin)
    java_home=$(readlink -f ~/jdkswitcher/java/jdk22)

else
    echo "Invalid option. Script is terminated"
    exit 1
fi

# Update the JAVA_PATH and JAVA_HOME in the profile file
update_profile "$profile_file" "$java_path" "$java_home"

# Reload the profile to apply the changes only once
source "$profile_file"

clear
java -version

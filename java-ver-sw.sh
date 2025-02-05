#!/bin/bash

profile_file="$HOME/.profile"
dir_path="$HOME/jreswitcher/java"
arch="$(uname -m)"
some_file="$dir_path/last_known_good_url.json"

mkdir -p "$dir_path"

# Function to update the JAVA_HOME and JAVA_PATH in the profile
update_profile() {
    local profile_file="$1"
    local java_path="$2"
    local java_home="$3"

    sed -i '/^export JAVA_HOME=/d' "$profile_file" 
    sed -i '/jreswitcher.*\/java.*\/jre/d' "$profile_file"
    sed -i '/^export PATH=/d' "$profile_file" 
    
    echo "export PATH=$java_path:\$PATH" >> "$profile_file"
    echo "export JAVA_HOME=$java_home" >> "$profile_file"
}

# Get the latest JRE version URL with Github API
getLatestURL() {
    local jre_ver="$1"

    if [ "$arch" = "x86_64" ]; then
        arch="x64"
    elif [ "$arch" = "armv7l" ]; then
        arch="arm"
    fi

    if grep -iq "alpine" /etc/os-release; then
        dist_suffix="_alpine-linux_"
    else
        dist_suffix="_linux_"
    fi

    local url
    url=$(curl -s "https://api.github.com/repos/adoptium/temurin${jre_ver}-binaries/releases/latest" | jq -r --arg arch "$arch" --arg suffix "$dist_suffix" '.assets[] | select(.name | contains("hotspot") and contains("jre") and contains($arch) and contains($suffix) and endswith(".tar.gz")) | .browser_download_url')

    if [ -z "$url" ]; then
        # Fallback: Check the JSON file for the saved URL
        if [ -f "$link_file" ]; then
            url=$(jq -r --arg ver "$jre_ver" '.[$ver]' "$some_file")
            if [ -z "$url" ]; then
                echo "Error: No URL found for JRE $jre_ver in the JSON file."
                exit 1
            fi
        else
            echo "Error: No URL found, and JSON file does not exist."
            exit 1
        fi
    fi

    echo "$url"
}

# Download JRE binary
downloader() {
    local jre_ver="$1"

    mkdir -p "$dir_path/jre${jre_ver}"
    cd "$dir_path/jre${jre_ver}"

    local url
    url=$(getLatestURL "$jre_ver")
    wget -q --show-progress "$url" || { echo "Download failed. Network issue or URL is expired."; sleep 5; exit 1; }

    # Save the URL to the JSON file
    if [ -f "$link_file" ]; then
        jq --arg ver "$jre_ver" --arg url "$url" '.[$ver] = $url' "$link_file" > "$link_file"
    else
        echo "{\"$jre_ver\": \"$url\"}" > "$link_file"
    fi
}


# Install the java path
installer() {
    local jre_ver="$1"

    cd "$dir_path/jre${jre_ver}" || { echo "Directory not found!"; exit 1; }
    tar --strip-components=1 -xvf *.tar.gz && rm *.tar.gz
    java_path=$(readlink -f "$dir_path/jre${jre_ver}/bin")
    java_home=$(readlink -f "$dir_path/jre${jre_ver}")

    update_profile "$profile_file" "$java_path" "$java_home"
    source "$profile_file"

    clear
    java -version
}

# Check for dependencies
for dep in wget jq tar; do
    if ! command -v $dep &> /dev/null; then
        echo "$dep is not installed. Installing..."
        sudo apt install -y $dep
    fi
done

clear

while true; do
    echo "Please choose a Java Runtime version: "
    echo "1. JRE 8"
    echo "2. JRE 17"
    echo "3. JRE 18"
    echo "4. JRE 21"
    echo "5. JRE 22"
    echo "6. JRE 23"
    echo "p. Delete all downloaded JRE"
    echo "0. Exit"
    echo "Current architecture: $(uname -m)"
    read -p "Option: " option
    clear

    case $option in
        1) downloader "8"; installer "8"; break ;;
        2) downloader "17"; installer "17"; break ;;
        3) downloader "18"; installer "18"; break ;;
        4) downloader "21"; installer "21"; break ;;
        5) downloader "22"; installer "22"; break ;;
        6) downloader "23"; installer "23"; break ;;
        p) rm -rf "$dir_path"/*; echo "All JREs deleted."; sleep 2; continue ;;
        0) exit 0 ;;
        *) echo "Invalid option. Try again."; sleep 2; continue ;;
    esac
done

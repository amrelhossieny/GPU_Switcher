#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Typewriter effect function
typewriter_effect() {
    text="$1"
    delay=${2:-0.05}  # Default delay of 0.05 seconds if not specified

    # Enable interpretation of backslash escapes
    echo -en "$text" | while IFS= read -r -n1 char; do
        echo -en "$char"
        sleep $delay
    done
    echo  # New line at the end
}

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> gpu_switcher.log
}

# Check if lspci is available
if ! command -v lspci &> /dev/null; then
typewriter_effect "$(echo -e "${RED}lspci command not found. Please install it to use this script.${NC}")" 0.02
    log "lspci command not found"
    exit 1
fi

# Function to get available GPUs
get_available_gpus() {
    mapfile -t available_gpus < <(lspci | grep -E 'VGA|3D|Display' | sed 's/.*: //')
    if [ ${#available_gpus[@]} -eq 0 ]; then
        typewriter_effect "$(echo -e "${RED}No GPUs detected. Exiting.${NC}")" 0.02 >&2
        log "No GPUs detected"
        exit 1
    fi
    printf '%s\n' "${available_gpus[@]}"
}



# Function to display available GPUs
show_available_gpus() {
    local -n gpus=$1
    typewriter_effect "Available GPUs:" 0.02
    for i in "${!gpus[@]}"; do
        typewriter_effect "$i: ${gpus[$i]}" 0.01
    done
}

# Function to display current GPU
show_current_gpu() {
    if command -v prime-select &> /dev/null; then
        current_gpu=$(prime-select query)
        case $current_gpu in
            nvidia)
                nvidia_gpu=$(lspci | grep -i 'nvidia' | sed 's/.*: //')
                typewriter_effect "$(echo -e "Current GPU: ${GREEN}$nvidia_gpu${NC}")" 0.02
                ;;
            intel)
                intel_gpu=$(lspci | grep -E 'VGA|3D controller' | grep -i 'intel' | sed 's/.*: //')
                typewriter_effect "$(echo -e "Current GPU: ${GREEN}$intel_gpu${NC}")" 0.02
                ;;
            *)
                typewriter_effect "$(echo -e "Current GPU: ${GREEN}$current_gpu${NC}")" 0.02
                ;;
        esac
    elif command -v nvidia-smi &> /dev/null; then
        typewriter_effect "$(echo -e "${YELLOW}prime-select not found, but NVIDIA driver detected. Use nvidia-settings for GPU management.${NC}")" 0.01
    else
        typewriter_effect "$(echo -e "${RED}Unable to determine current GPU. GPU switching may not be supported on this system.${NC}")" 0.01
    fi
}

# Function to switch GPU
switch_gpu() {
    local gpu=${available_gpus[$1]}
    local gpu_lower=$(echo $gpu | tr '[:upper:]' '[:lower:]')
    local gpu_select=""

    if [[ $gpu_lower == *"intel"* ]]; then
        gpu_select="intel"
    elif [[ $gpu_lower == *"nvidia"* ]]; then
        gpu_select="nvidia"
    elif [[ $gpu_lower == *"amd"* || $gpu_lower == *"radeon"* ]]; then
        typewriter_effect "$(echo -e "${YELLOW}AMD GPU detected. Please use the appropriate AMD switching tool.${NC}")" 0.01
        log "AMD GPU detected, unable to switch"
        return 1
    else
        typewriter_effect "$(echo -e "${RED}Unsupported GPU type. Exiting.${NC}")" 0.01
        log "Unsupported GPU type: $gpu"
        return 1
    fi
    
    if command -v prime-select &> /dev/null; then
        if sudo prime-select $gpu_select; then
            typewriter_effect "$(echo -e "${GREEN}Successfully switched to $gpu_select GPU.${NC}")" 0.02
            log "Switched to $gpu_select GPU"
            
            typewriter_effect "$(echo -e "A reboot is recommended to fully apply changes and ensure all components use the new GPU.")" 0.01
            while true; do
                read -p "$(echo -e "${NC}Would you like to reboot now? (Y/N): ${GREEN}")" reboot_choice
                echo -en "${NC}"
                case $reboot_choice in
                    [Yy]*)
                        log "User chose to reboot"
                        typewriter_effect "$(echo -e "Rebooting in 10 seconds...")" 0.02
                        sleep 10
                        sudo reboot
                        ;;
                    [Nn]*)
                        typewriter_effect "$(echo -e "Changes will not be fully applied until next reboot.")" 0.01
                        log "User chose not to reboot"
                        break
                        ;;
                    *)
                        echo -e "\r${NC}Would you like to reboot now? (Y/N): ${RED}$reboot_choice${NC}"
                        typewriter_effect "$(echo -e "${RED}Invalid choice. Please enter Y or N.${NC}")" 0.01
                        ;;
                esac
            done
        else
            typewriter_effect "$(echo -e "${RED}Failed to switch GPU. Please check your permissions or system configuration.${NC}")" 0.01
            log "Failed to switch GPU: $(sudo prime-select $gpu_select 2>&1)"
            return 1
        fi
    elif command -v nvidia-smi &> /dev/null; then
        typewriter_effect "$(echo -e "${YELLOW}prime-select not found, but NVIDIA driver detected. Use nvidia-settings for GPU management.${NC}")" 0.01
        log "prime-select not found, NVIDIA driver detected"
        return 1
    else
        typewriter_effect "$(echo -e "${RED}Unable to switch GPU. GPU switching may not be supported on this system.${NC}")" 0.01
        log "Unable to switch GPU, system may not support switching"
        return 1
    fi
}

# Main script
log "Script started"
mapfile -t available_gpus < <(get_available_gpus)
show_available_gpus available_gpus
show_current_gpu

typewriter_effect "$(echo -e "Enter the number corresponding to the GPU you want to switch to:")" 0.02
read -p "$(echo -e "${NC}Your choice: ${GREEN}")" choice
echo -en "${NC}"


if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    typewriter_effect "$(echo -e "${RED}Invalid input. Please enter a number.${NC}")" 0.01
    log "Invalid input: $choice"
    exit 1
fi

if [[ $choice -ge 0 && $choice -lt ${#available_gpus[@]} ]]; then
    switch_gpu $choice
else
    typewriter_effect "$(echo -e "${RED}Invalid choice. Please select a number between 0 and $((${#available_gpus[@]} - 1)).${NC}")" 0.01
    log "Invalid GPU choice: $choice"
    exit 1
fi

log "Script ended"

#!/bin/bash

# Function to display a welcome message
info() {
    clear
    echo "Welcome to Yuna Management Script!"
}

# Function to display a goodbye message
goodbye() {
    echo "Thank you for using Yuna Management Script. Goodbye!"
}

# Function to start Yuna
start_yuna() {
    echo "Starting Yuna..."
    python index.py
}

# Function to install or update dependencies
install_update_dependencies() {
    clear
    while true; do
    echo "========== Installation... =========="
    echo "1. CPU"
    echo "2. NVIDIA GPU"
    echo "3. AMD GPU"
    echo "4. Metal"
    echo "5. Go back" 

    read -p "> " install_choice

    case $install_choice in
        1) install_cpu;;
        2) install_nvidia;;
        3) install_amd;;
        4.) install_metal;;
        5) return;;
        *) echo "Invalid choice. Please enter a number between 1 and 5.";;
    esac
    done
}

install_cpu() {
    echo "Installing CPU dependencies..."
    pip install -r requirements.txt
    echo "CPU dependencies installed."
    
}

install_nvidia() {
    echo "Installing NVIDIA dependencies..."
    CMAKE_ARGS="-DLLAMA_CUBLAS=on" pip install llama-cpp-python
    pip install -r requirements-nvidia.txt
    echo "NVIDIA dependencies installed."
    
}

install_amd() {
    echo "Installing AMD dependencies..."
    # YOU NEED TO SPECIFY THE CORRECT GFX NUMBER FOR YOUR GPU
    # THE DEFAULT IS GFX1100 - which was used since I have a  RX7600
    # Check the Shader ISA Instruction Set for your GPU
    CMAKE_ARGS="-DLLAMA_HIPBLAS=ON -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++ -DCMAKE_PREFIX_PATH=/opt/rocm -DAMDGPU_TARGETS=gfx1100" FORCE_CMAKE=1 pip install llama-cpp-python
    CMAKE_ARGS="-DLLAMA_HIPBLAS=on" pip install llama-cpp-python
    pip install -r requirements-amd.txt
    echo "AMD dependencies installed."
    
}

install_metal() {
    echo "Installing Metal dependencies..."
    CMAKE_ARGS="-DLLAMA_METAL=on" pip install llama-cpp-python
    pip install -r requirements-macos.txt
    echo "Metal dependencies installed."
    
}


# Submenu for configure()
configure_submenu() {
    while true; do
        clear

        echo "========== Configure Menu =========="
        echo "1. Install models"
        echo "2. Clear models"
        echo "3. Backup"
        echo "4. Restore"
        echo "5. Go back"
        echo "6. Exit"

        # Read user input
        read -p "> " config_choice

        # Execute the corresponding function based on user input
        case $config_choice in
            1) install_models;;
            2) clear_models;;
            3) backup;;
            4) restore;;
            5) break;; # Go back
            6) goodbye; exit;; # Exit
            *) echo "Invalid choice. Please enter a number between 1 and 6.";;
        esac

        # Add a newline for better readability
        echo
    done
}

# Function to configure
configure() {
    configure_submenu
}

# Function to install models
install_models() {
    clear
    echo "========== Install Models Menu =========="
    echo " 1. All"
    echo " 2. All AGI"
    echo " 3. Vision"
    echo " 4. Art"
    echo " 5. Emotion"
    echo " 6. Yuna"
    echo " 7. Go back"
    echo " 8. Exit"

    # Read user input
    read -p "Enter your choice (1-6): " install_choice

    case $install_choice in
        1) install_all_models;;
        2) install_all_agi_models;;
        3) install_vision_model;;
        4) install_art_model;;
        5) install_emotion_model;;
        6) install_yuna_model;;
        7) return;;
        8) goodbye; exit;;
        *) echo "Invalid choice. Please enter a number between 1 and 6.";;
    esac
}

# Function to install all models
install_all_models() {
    install_all_agi_models
    install_yuna_model
}

# Function to install all AGI models
install_all_agi_models() {
    echo "Installing all AGI models..."
    install_vision_model
    install_art_model
    install_emotion_model
}

# Function to install Vision model
install_vision_model() {
    echo "Installing Vision model..."
    git clone https://huggingface.co/yukiarimo/yuna-vision lib/models/agi/yuna-vision/
}

# Function to install Art model
install_art_model() {
    echo "Installing Art model..."
    wget https://huggingface.co/yukiarimo/anyloli/resolve/main/any_loli.safetensors -P lib/models/agi/art/
}

# Function to install Vision model
install_emotion_model() {
    echo "Installing Vision model..."
    git clone https://huggingface.co/yukiarimo/yuna-emotion lib/models/agi/yuna-emotion/
}

# Function to install Yuna model
install_yuna_model() {
    echo "Installing Yuna model..."
    wget https://huggingface.co/yukiarimo/yuna-ai/resolve/main/yuna-ggml-q5.gguf -P lib/models/yuna/
}

# Function to clear models
clear_models() {
    clear
    echo "========== Clear Models Menu =========="
    echo "This will delete all models inside 'lib/models/'."
    read -p "Do you want to proceed? (y/n): " confirm_clear

    case $confirm_clear in
        [Yy])
            echo "Clearing models..."
            rm -rf lib/models/*
            echo "Models cleared."
            ;;
        [Nn])
            echo "Operation canceled. No models were cleared."
            ;;
        *)
            echo "Invalid choice. Please enter 'y' or 'n'."
            ;;
    esac
}

# Function to backup
backup() {
    clear
    echo "Backing up..."
    # Add your code here for backup
}

# Function to restore
restore() {
    clear
    echo "Restoring..."
    # Add your code here for restore
}

oneClickInstall() {
    install_update_dependencies
    install_models

    read -p "Do you want to start Yuna? (y/n): " confirm_start

    case $confirm_start in
        [Yy])
            start_yuna
            ;;
        [Nn])
            echo "Operation canceled. Everything is installed."
            ;;
        *)
            echo "Invalid choice. Please enter 'y' or 'n'."
            ;;
    esac
}

contribute() {
    clear
    echo "========== Contribute to Yuna =========="
    echo "Yuna is an open source project. The following commands will help you to contribute to Yuna."
    echo "git fetch origin main\ngit merge main\ngit push origin dev:main\n"
    echo "Do you want to proceed? (y/n): " confirm_contribute

    case $confirm_contribute in
        [Yy])
            echo "Contribute to Yuna..."
            git fetch origin main
            git merge main
            git push origin dev:main
            echo "Contribute to Yuna done."
            ;;
        [Nn])
            echo "Operation canceled. No contribution was made."
            ;;
        *)
            echo "Invalid choice. Please enter 'y' or 'n'."
            ;;
    esac
}

donate() {
    clear
    echo "========== Donate =========="
    echo "Yuna is an open source project. You can support the development of Yuna by donating."
    echo "1. https://www.patreon.com/YukiArimo"
    echo "2. https://ko-fi.com/yukiarimo"

    read -p "Enter your choice (1-2): " donate_choice

    case $donate_choice in
        1) xdg-open https://www.patreon.com/YukiArimo;;
        2) xdg-open https://ko-fi.com/yukiarimo;;
        *) echo "Invalid choice. Please enter a number between 1 and 2.";;
    esac
}

# Display the main menu
while true; do
    clear

    echo "========== Main Menu =========="
    echo "1. Start Yuna"
    echo "2. Install or Update dependencies"
    echo "3. One click install"
    echo "4. Configure"
    echo "5. Reset"
    echo "6. Exit"
    echo "7. Contribute to Yuna"
    echo "8. Info"
    echo "9. Donate"
    echo "10. Exit"

    # Read user input
    read -p "> " choice

    # Execute the corresponding function based on user input
    case $choice in
        1) start_yuna;;
        2) install_update_dependencies;;
        3) oneClickInstall;;
        4) configure;;
        5) reset;;
        6) goodbye; exit;;
        7) contribute;;
        8) info;;
        9) donate;;
        10) goodbye; exit;;
        *) echo "Invalid choice. Please enter a number between 1 and 5.";;
    esac

    # Add a newline for better readability.
    echo
done
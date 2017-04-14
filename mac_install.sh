#!/bin/bash
# thoride installation script

#####################################################################################################
# Variables
#####################################################################################################

SYSTEM_PACKAGE_MANAGER=""
SYSTEM_PACKAGE_TYPE="brew"
SYSTEM_PACKAGE_MANAGER_INSTALL="brew install"
SYSTEM_PACKAGE_MANAGER_UNINSTALL="brew remove"
SYSTEM_PACKAGE_MANAGER_UPDATE="brew update"
SYSTEM_PACKAGE_SET="vim macvim git wget python"
SYSTEM_PACKAGE_CLEAN="vim"
THORIDE_INSTALL_DIR_DEFAULT="/opt" 
PIP_INSTALL_CMD="pip install"
PIP_PACKAGE_SET="clang watchdog"


guess_system_package_manager() {
    if [ "`which brew`" != "" ]; then
        SYSTEM_PACKAGE_MANAGER="brew"
    fi
    }


print_usage(){
    echo -e "Usage: './install.sh <directory>'"
    echo -e "Args:  <directory>"
    echo -e "           Optional argument defining installation directory. Default one is '"$THORIDE_INSTALL_DIR_DEFAULT"'"
}

#####################################################################################################
# Plugins
#####################################################################################################

# Nerdtree
PLUGINS="$PLUGINS https://github.com/scrooloose/nerdtree"

# # Clang_complete
# PLUGINS="$PLUGINS https://github.com/Rip-Rip/clang_complete"

# YouCompleteMe
PLUGINS="$PLUGINS https://github.com/Valloric/YouCompleteMe"

# Syntastic
#PLUGINS="$PLUGINS https://github.com/vim-syntastic/syntastic.git"

# Flake-8
#PLUGINS="$PLUGINS https://github.com/nvie/vim-flake8"

# SimplyFold
#PLUGINS="$PLUGINS https://github.com/tmhedberg/SimpylFold"

# SuperTab
PLUGINS="$PLUGINS https://github.com/ervandew/supertab"

# Tagbar
PLUGINS="$PLUGINS https://github.com/majutsushi/tagbar"

# Airline
PLUGINS="$PLUGINS https://github.com/bling/vim-airline"
PLUGINS="$PLUGINS https://github.com/vim-airline/vim-airline-themes"

# A
PLUGINS="$PLUGINS https://github.com/vim-scripts/a.vim"

# Auto-close
PLUGINS="$PLUGINS https://github.com/Townk/vim-autoclose"

# Multiple-cursors
PLUGINS="$PLUGINS https://github.com/terryma/vim-multiple-cursors.git"

# NERDCommenter
PLUGINS="$PLUGINS https://github.com/scrooloose/nerdcommenter"

# UltiSnips
PLUGINS="$PLUGINS https://github.com/SirVer/ultisnips"

# Git
PLUGINS="$PLUGINS https://github.com/tpope/vim-fugitive.git"
PLUGINS="$PLUGINS https://github.com/airblade/vim-gitgutter.git"

# Conque-GDB
PLUGINS="$PLUGINS https://github.com/vim-scripts/Conque-GDB"

# Pathogen
PLUGINS="$PLUGINS https://github.com/tpope/vim-pathogen"

# Color schemes
SCHEMES="$SCHEMES https://github.com/JBakamovic/yaflandia.git"
SCHEMES="$SCHEMES https://github.com/jeffreyiacono/vim-colors-wombat"
SCHEMES="$SCHEMES https://github.com/morhetz/gruvbox.git"
SCHEMES="$SCHEMES https://github.com/jnurmine/Zenburn"
SCHEMES="$SCHEMES https://github.com/altercation/vim-colors-solarized"

#####################################################################################################
# Setup the installation directory
#####################################################################################################
THORIDE_INSTALL_DIR=$THORIDE_INSTALL_DIR_DEFAULT
if [ $# -eq 0 ]; then
    THORIDE_INSTALL_DIR=$THORIDE_INSTALL_DIR"/thoride"
    echo "Using default installation directory: '"$THORIDE_INSTALL_DIR"'"
elif [ $# -eq 1 ]; then
    THORIDE_INSTALL_DIR=${1%/}
    if [ ! -d $THORIDE_INSTALL_DIR ]; then
        echo "Directory '"$THORIDE_INSTALL_DIR"' does not exist."
        print_usage
        echo "Exiting ..."
        exit
    fi
    THORIDE_INSTALL_DIR=$THORIDE_INSTALL_DIR"/thoride"
    echo "Using user-defined installation directory: '"$THORIDE_INSTALL_DIR"'"
else
    echo "Invalid number of arguments!"
    print_usage
    echo "Exiting ..."
    exit
fi

#####################################################################################################
# Identify the system package manager
#####################################################################################################
guess_system_package_manager
if [ -z $SYSTEM_PACKAGE_MANAGER ]; then
    echo "Uh-oh! Seems like you don't have homebrew. Please install it and try again."
fi
echo "System package manager: '"$SYSTEM_PACKAGE_MANAGER"'"
echo "System package type: '"$SYSTEM_PACKAGE_TYPE"'"

#####################################################################################################
# Root password needed for some operations
#####################################################################################################
CURRENT_USER=`whoami`
echo -n "Enter the password for $CURRENT_USER: "
stty_orig=`stty -g` # save original terminal setting.
stty -echo          # turn-off echoing.
read passwd         # read the password
stty $stty_orig     # restore terminal setting.

#####################################################################################################
# Install dependencies
#####################################################################################################
echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing Dependencies ..."
echo "----------------------------------------------------------------------------"

$SYSTEM_PACKAGE_MANAGER_UPDATE
$SYSTEM_PACKAGE_MANAGER_UNINSTALL $SYSTEM_PACKAGE_CLEAN
$SYSTEM_PACKAGE_MANAGER_INSTALL $SYSTEM_PACKAGE_SET
$PIP_INSTALL_CMD $PIP_PACKAGE_SET

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing Fonts ..."
echo "----------------------------------------------------------------------------"

mkdir -p $HOME/.fonts && git clone https://github.com/Lokaltog/powerline-fonts.git $HOME/.fonts
$HOME/.fonts/install.sh
rm -rf $HOME/.fonts
#fc-cache -vf $HOME/.fonts

# #####################################################################################################
# # Start the installation
# #####################################################################################################

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Copying Files ..."
echo "----------------------------------------------------------------------------"

# Build the destination directory and copy all of the relevant files
echo "$passwd" | sudo -S mkdir -p $THORIDE_INSTALL_DIR
echo "$passwd" | sudo -S cp -R ./config $THORIDE_INSTALL_DIR
echo "$passwd" | sudo -S cp ./.vimrc $THORIDE_INSTALL_DIR
echo "$passwd" | sudo -S cp ./res $THORIDE_INSTALL_DIR
#echo "$passwd" | sudo -S cp -R . $THORIDE_INSTALL_DIR

# # Make Thoride accessible via 'Applications' menu and via application launcher
echo "$passwd" | sudo -S cp -rf res/thoride.app /Applications

# # Make Thoride accessible in terminal
echo "alias thoride=\"mvim -u /opt/thoride/.vimrc\"" >> $HOME/.zshrc

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing plugins ..."
echo "----------------------------------------------------------------------------"

echo "$passwd" | sudo -S mkdir -p $THORIDE_INSTALL_DIR/plugins && cd $THORIDE_INSTALL_DIR/plugins

# Fetch/update the plugins
for URL in $PLUGINS; do
    # remove path from url
    DIR=${URL##*/}
    # remove extension from dir
    DIR=${DIR%.*}
    if [ -d $DIR  ]; then
        echo "Updating plugin $DIR..."
        cd $DIR
        echo "$passwd" | sudo -S git pull
        cd ..
    else
        echo "$passwd" | sudo -S git clone $URL $DIR
    fi
done

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing YouCompleteMe ..."
echo "----------------------------------------------------------------------------"

cd $THORIDE_INSTALL_DIR/plugins/YouCompleteMe
echo "$passwd" | sudo -S git submodule update --init --recursive
echo "$passwd" | sudo -S EXTERNAL_LIBCLANG_PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib" ./install.py --clang-completer

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing cppcheck ..."
echo "----------------------------------------------------------------------------"

cd $THORIDE_INSTALL_DIR/plugins
echo "$passwd" | sudo -S mkdir cppcheck && cd cppcheck
echo "$passwd" | sudo -S mkdir download && cd download
echo "$passwd" | sudo -S wget http://sourceforge.net/projects/cppcheck/files/cppcheck/1.67/cppcheck-1.67.tar.bz2/download -O cppcheck.tar.bz2
echo "$passwd" | sudo -S tar xf cppcheck.tar.bz2 && cd cppcheck-1.67
echo "$passwd" | sudo -S make install SRCDIR=build CFGDIR=$THORIDE_INSTALL_DIR/plugins/cppcheck/cfg HAVE_RULES=yes
cd ../../
echo "$passwd" | sudo -S rm -r download

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing color schemes ..."
echo "----------------------------------------------------------------------------"

echo "$passwd" | sudo -S mkdir -p $THORIDE_INSTALL_DIR/colors && cd $THORIDE_INSTALL_DIR/colors

# Fetch/update the color schemes
for URL in $SCHEMES; do
    # remove path from url
    DIR=${URL##*/}
    # remove extension from dir
    DIR=${DIR%.*}
    if [ -d $DIR  ]; then
        echo "Updating scheme $DIR..."
        cd $DIR
        echo "$passwd" | sudo -S git pull
        cd ..
    else
        echo "$passwd" | sudo -S git clone $URL $DIR
	fi
done

# Make symlinks to scheme files
echo "$passwd" | sudo -S ln -s `find . -wholename '*/colors/*.vim'` .

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Setting permissions ..."
echo "----------------------------------------------------------------------------"
echo "$passwd" | sudo -S chown -R $USER $THORIDE_INSTALL_DIR

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installation complete."
echo "----------------------------------------------------------------------------"

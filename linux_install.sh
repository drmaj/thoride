#!/bin/bash
# thoride installation script

#####################################################################################################
# Variables
#####################################################################################################

SYSTEM_PACKAGE_MANAGER=""
SYSTEM_PACKAGE_TYPE="deb"
SYSTEM_PACKAGE_MANAGER_INSTALL="apt-get -y install"
SYSTEM_PACKAGE_MANAGER_UNINSTALL="apt-get -y uninstall"
SYSTEM_PACKAGE_MANAGER_UPDATE="apt-get update"
SYSTEM_PACKAGE_SET="build-essential cmake vim-gnome vim ctags cscope git wget libpcre3 libpcre3-dev libyaml-dev python-pip python-dev python3-dev python3-pip libclang-dev"
SYSTEM_PACKAGE_CLEAN="vim"
THORIDE_INSTALL_DIR_DEFAULT="/opt" 
PIP_INSTALL_CMD="pip install"
PIP_PACKAGE_SET="clang watchdog"

guess_system_package_manager() {
	if [ "`which apt-get`" != "" ]; then
	    SYSTEM_PACKAGE_MANAGER="apt-get"
	    echo SYSTEM_PACKAGE_MANAGER
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
PLUGINS="$PLUGINS https://github.com/jistr/vim-nerdtree-tabs"

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

# Auto Pairs
PLUGINS="$PLUGINS https://github.com/jiangmiao/auto-pairs"

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
    echo "Uh-oh! Seems like you don't have apt-get. Please install it and try again."
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

echo "$passwd" | sudo -S $SYSTEM_PACKAGE_MANAGER_UPDATE
echo "$passwd" | sudo -S $SYSTEM_PACKAGE_MANAGER_UNINSTALL $SYSTEM_PACKAGE_CLEAN
echo "$passwd" | sudo -S $SYSTEM_PACKAGE_MANAGER_INSTALL $SYSTEM_PACKAGE_SET
echo "$passwd" | sudo -S $PIP_INSTALL_CMD $PIP_PACKAGE_SET

echo -e "\n"
echo "----------------------------------------------------------------------------"
echo "Installing Fonts ..."
echo "----------------------------------------------------------------------------"

mkdir -p $HOME/.fonts && git clone https://github.com/Lokaltog/powerline-fonts.git $HOME/.fonts
fc-cache -vf $HOME/.fonts

# #####################################################################################################
# # Start the installation
# #####################################################################################################

# Build the destination directory and copy all of the relevant files
echo "$passwd" | sudo -S mkdir -p $THORIDE_INSTALL_DIR
echo "$passwd" | sudo -S cp -R ./config $THORIDE_INSTALL_DIR
echo "$passwd" | sudo -S cp ./.vimrc $THORIDE_INSTALL_DIR
echo "$passwd" | sudo -S cp -R ./res $THORIDE_INSTALL_DIR

echo "Searching for 'libclang' paths ..."
declare -a libclang_paths
paths=`find /usr -path "/usr/lib*/libclang.so"`
libclang_paths=( ${paths} )
echo "Found" ${#libclang_paths[@]} "'libclang' paths in total."
if [ ${#libclang_paths[@]} != 0 ]; then
    for (( i = 0; i < ${#libclang_paths[@]}; i++ ));
    do
        echo ${libclang_paths[$i]}
    done
    libclang_selected=${libclang_paths[${#libclang_paths[@]}-1]}
    echo "Selected 'libclang' is '"$libclang_selected"'"
    echo "$passwd" | sudo -S sed -i -e '$alet g:libclang_location = "'${libclang_paths}'"' $THORIDE_INSTALL_DIR/config/.user_settings.vimrc
fi

# Make thoride accessible in the terminal
echo "alias thoride=\"gvim -u /opt/thoride/.vimrc\"" >> $HOME/.bashrc

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
echo "$passwd" | sudo -S YCM_CORES=1 ./install.py --clang-completer

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


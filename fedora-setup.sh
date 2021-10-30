#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
HEIGHT=15
WIDTH=90
CHOICE_HEIGHT=4
BACKTITLE="Fedora Setup Util - By Osiris - https://stealingthe.network"
TITLE="Make a selection"
MENU="Please Choose one of the following options:"

#Check to see if Dialog is installed, if not install it
if [ $(dpkg-query -W -f='${Status}' dialog 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  sudo dnf install -y dialog;
fi



OPTIONS=(1 "Enable RPM Fusion"
         2 "Enable Flathub"
         3 "Speed up DNF"
         4 "Install Nvidia"
         5 "Enable Better Fonts"
         6 "Install Tweaks, Plugins & Extensions"
         7 "Install winehq-staging for Fedora 34"
         8 "Install winehq-staging for Fedora 35"
         9 "Install winetricks"
         10 "Install Microsoft Edge"
         11 "Install Common Software"
         12 "Disable firewalld"
         37 "Quit")

while [ "$CHOICE -ne 4" ]; do
    CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --nocancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

    clear
    case $CHOICE in
        1)  echo "Enabling RPM Fusion"
            sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            sudo dnf upgrade --refresh
            sudo dnf groupupdate -y core
            sudo dnf install -y rpmfusion-free-release-tainted
            sudo dnf install -y dnf-plugins-core
           ;;
        2)  echo "Swappiness Tweak"
            echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
           ;;
        3)  echo "Speeding Up DNF"
            echo "#Custom changes" | sudo tee -a /etc/dnf/dnf.conf
            echo 'defaultyes=True' | sudo tee -a /etc/dnf/dnf.conf
            echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
            echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
            echo 'deltarpm=True' | sudo tee -a /etc/dnf/dnf.conf
           ;;
        4)  echo "Installing Nvidia driver and tools"
            sudo dnf install -y akmod-nvidia
            sudo dnf install -y xorg-x11-drv-nvidia-cuda
            sudo dnf install -y xorg-x11-drv-nvidia-cuda-libs
            sudo dnf install -y xorg-x11-drv-nvidia-power
            sudo dnf install -y vdpauinfo libva-vdpau-driver libva-utils
            sudo dnf install -y vulkan
            sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
            sudo systemctl enable nvidia-{suspend,resume,hibernate}
           ;;
        5)  echo "Enabling Better Fonts by Dawid"
            sudo -s dnf -y copr enable dawid/better_fonts
            sudo -s dnf install -y fontconfig-font-replacements
            sudo -s dnf install -y fontconfig-enhanced-defaults
           ;;
        6)  echo "Installing Tweaks, extensions & plugins"
            sudo dnf groupupdate -y sound-and-video
            sudo dnf install -y libdvdcss
            sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,ugly-\*,base} gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
            sudo dnf install -y lame\* --exclude=lame-devel
            sudo dnf group upgrade -y --with-optional Multimedia
           ;;
        7)  echo "Installing winehq-staging for F34"
            sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/34/winehq.repo
            sudo dnf install -y winehq-staging
           ;;
        8)  echo "Installing winehq-staging for F35"
            sudo dnf config-manager --add-repo winehq.fedora.35.repo
            sudo dnf install -y winehq-staging
           ;;
        9)  echo "Installing winetricks"
            wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
            chmod +x winetricks
            sudo mv winetricks /usr/bin
            wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.bash-completion
            sudo mv winetricks.bash-completion /usr/share/bash-completion/completions/winetricks
            wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks.1
            sudo mv winetricks.1 /usr/share/man/man1/winetricks.1
           ;;
       10)  echo "Installing microsoft edge beta"
            sudo rpm -v --import https://packages.microsoft.com/keys/microsoft.asc
            sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
            sudo mv /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge-beta.repo
            sudo dnf install -y microsoft-edge-beta
           ;;
       11)  echo "Installing Software"
            sudo dnf install -y mediainfo steam plex-media-player gnome-disk-utility unrar unzip mangohud gamemode numlockx mscore-fonts-all audacious audacious-plugins neofetch cpufetch papirus-icon-theme celluloid cmatrix gparted kvantum okular p7zip protontricks
           ;;
       12)  echo "Disabling Firewalld Service"
            sudo systemctl stop firewalld.service
            sudo systemctl disable firewalld.service
           ;;
       37)
          exit 0
          ;;
    esac
done

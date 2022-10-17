# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  DPI=144;
in
{
  imports =
    [ # Include the results of the hardware scan
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  # boot.loader.grub.extraGrubInstallArgs = [ "--target=x86_64-efi" ];
  boot.loader.grub.device = "nodev";
  # boot.loader.grub.device = "/dev/vda";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.useOSProber = false;
  boot.loader.grub.splashImage = ../assets/grub_splash.tga;
  # boot.loader.grub.backgroundColor = "#123456";
  boot.loader.grub.extraEntries = ''
    menuentry "================================================================================" {
      true
    }
    menuentry "Firmware setup" {
      fwsetup
    }
    menuentry "Reboot" {
      reboot
    }
    menuentry "Poweroff" {
      halt
    }
    menuentry "================================================================================" {
      true
    }
  '';

  networking.hostName = "nixos"; # Define your hostname
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant

  networking.extraHosts = "
     192.168.1.111 lisy
     192.168.1.100 speedy
     192.168.1.7   printer
  ";

  # Include ~/bin/ in $PATH
  environment.homeBinInPath = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system
  services.xserver.enable = true;
  services.xserver.dpi = DPI;

  # Enable the KDE Plasma Desktop Environment
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.enableHidpi = false;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.windowManager.openbox.enable = true;
  services.xserver.windowManager.icewm.enable = true;
  services.xserver.displayManager.defaultSession = "plasma";
  # services.xserver.displayManager.defaultSession = "plasma+openbox";
  # services.xserver.displayManager.defaultSession = "none+openbox";
  services.xserver.displayManager.sddm.theme = "${(pkgs.fetchFromGitHub {
    owner = "energos";
    repo = "kde-plasma-chili";
    rev = "2ca77d5b73a7bf82ad4cd49f6fac19e5cee5e4a2";
    sha256 = "+IefkzZPuCZC4RkwNAGnThF/o+ChXizL3wuW3i8nW7E=";
  })}";

  # Configure keymap in X11
  services.xserver = {
    layout = "us,us";
    xkbVariant = "intl,basic";
    xkbOptions = "grp:shifts_toggle,grp_led:caps,terminate:ctrl_alt_bksp,caps:none,lv3:ralt_switch_multikey";
  };

  # Configure console keymap and font
  console.keyMap = "us-acentos";
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-128b.psf.gz";

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager)
  # services.xserver.libinput.enable = true;

  # Enable plocate
  services.locate = {
    enable = true;
    locate = pkgs.plocate;
    localuser = null;
    interval = "never";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.energos = {
    isNormalUser = true;
    description = "Energos";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      # firefox-esr
      kate
      konsole
      okular
      calibre
      sqlite
      libreoffice
      inkscape
      libsForQt5.kdegraphics-thumbnailers
      libsForQt5.kpat
      spectacle
      qiv
      emacs-gtk
      geany
      kdiff3
      artha
      cmus
      libmad
      mpv
      yt-dlp
      gkrellm
      xfontsel
      xorg.xdpyinfo
      xorg.xev
      xorg.xmodmap
      xorg.xmessage
      xorg.mkfontdir
      xdotool
      wmctrl
      julia-bin
    ];
  };

  programs.bash.promptInit = ''
    if [[ ''${EUID} == 0 ]] ; then
        PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
    else
        # Add git branch to bash prompt
        git_prompt=/run/current-system/sw/share/git/contrib/completion/git-prompt.sh
        if [[ -r $git_prompt ]] ; then
            source $git_prompt
            # from another distro's /etc/bash/bashrc
            # PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
            # from another distro's /usr/share/git/git-prompt.sh
            # PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
            # slice, mix and shake:
            PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;35m\]$(__git_ps1 " (%s)") \[\033[01;34m\]\$\[\033[00m\] '
            GIT_PS1_SHOWDIRTYSTATE=1
        else
            PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
        fi
    fi
  '';

  programs.bash.interactiveShellInit = ''
    # Search history
    if [[ ! -v INSIDE_EMACS ]]; then
        bind '"\e[A": history-search-backward'
        bind '"\e[B": history-search-forward'
    fi
    # preserve history
    HISTFILESIZE=100000
    HISTSIZE=100000
    shopt -s histappend
    # don't include duplicates in history
    # don't include lines beggining with spaces
    HISTCONTROL=ignoreboth
    # list size in megabytes
    export BLOCKSIZE=M
    # your favorite editor
    export EDITOR=zile
  '';

  programs.bash.shellAliases = {
    l = null;
    ll = null;
    egrep = "egrep --color=auto";
    fgrep = "fgrep --color=auto";
    grep = "grep --color=auto";
    ls = "ls --color=auto";
    mc = "mc -d";
    less = "less -i";
    zless = "zless -i";
  };

  fonts.fonts = with pkgs; [
    xorg.fontbhlucidatypewriter75dpi
    xorg.fontbhlucidatypewriter100dpi
    xorg.fontbh75dpi
    xorg.fontbh100dpi
    xorg.fontmiscmisc
    dejavu_fonts
    inconsolata
    iosevka-bin
    hack-font
    terminus_font
    liberation_ttf
    fira-code
    fira-code-symbols
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.

    grub2_efi
    efibootmgr

    gtk3
    shellcheck
    wget
    zile
    joe
    emacs-nox
    tmux
    xclip
    mc
    htop
    neofetch
    fortune
    figlet
    graphviz
    skim
    silver-searcher
    ripgrep
    fd
    file
    gnumake
    autoconf
    automake
    gcc
    gdb
    git
    bc
    pciutils
    usbutils
    lsof
    psmisc
    evtest
    nmap
    socat
    netcat-openbsd
    bat
    rxvt-unicode
    xterm
    xtermcontrol
    gforth
    nix-index
    nixos-option
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    baseIndex = 1;
    clock24 = true;
    historyLimit = 100000;
    extraConfig = ''
      set -g prefix S-F1
      set -g prefix2 C-b
      bind S-F1 send-prefix -2
      bind C-b send-prefix -2
      bind r source-file ~/.tmux.conf \; display "Reloaded!"
      unbind %
      unbind '"'
      bind | split-window -h
      bind '\' split-window -h
      bind - split-window -v
      set -g repeat-time 500
      set -g status-style fg=white,bg=black
      set -g window-status-style fg=cyan,bg=default,dim
      set -g window-status-current-style fg=white,bg=blue,bright
      set -g pane-border-style fg=white,bg=black
      set -g pane-active-border-style fg=cyan,bg=black
      set -g message-style fg=white,bg=black,bright
      set -g status-justify centre
      bind C-c run -b "tmux save-buffer - | xclip -i"
      bind C-v run -b "tmux set-buffer \"$(xclip -o)\"; tmux paste-buffer"
      unbind +
      unbind =
      bind + new-window -d -n tmux-zoom  \; swap-pane -s tmux-zoom.0 \; select-window -t tmux-zoom
      bind = last-window \; swap-pane -s tmux-zoom.0 \; kill-window -t tmux-zoom
      bind b choose-buffer
    '';
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  # Clipboard and auto resize for qemu guests
  services.spice-vdagentd.enable = true;
  # Dunno...
  services.qemuGuest.enable = true;

  # Open ports in the firewall
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

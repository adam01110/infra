{
  perSystem = {pkgs, ...}: let
    inherit
      (builtins)
      # keep-sorted start
      filter
      # keep-sorted end
      ;
    inherit (pkgs) buildFHSEnv;

    # Slim lutris provides minimal lutris with essential dependencies.
    qt5Deps = pkgs:
      with pkgs.qt5; [
        # keep-sorted start
        qtbase
        qtmultimedia
        # keep-sorted end
      ];
    qt6Deps = pkgs:
      with pkgs.qt6; [
        # keep-sorted start
        qtbase
        # keep-sorted end
      ];
    gnomeDeps = pkgs:
      with pkgs; [
        # keep-sorted start
        adwaita-icon-theme
        gtksourceview
        libgnome-keyring
        webkitgtk_4_1
        zenity
        # keep-sorted end
      ];
    xorgDeps = pkgs:
      with pkgs; [
        # keep-sorted start
        libice
        libpthread-stubs
        libsm
        libx11
        libxaw
        libxcb
        libxcomposite
        libxcursor
        libxdmcp
        libxext
        libxfixes
        libxi
        libxinerama
        libxmu
        libxrandr
        libxrender
        libxscrnsaver
        libxt
        libxtst
        libxv
        libxxf86vm
        # keep-sorted end
      ];
    gstreamerDeps = pkgs:
      with pkgs.gst_all_1; [
        # keep-sorted start
        gst-libav
        gst-plugins-bad
        gst-plugins-base
        gst-plugins-good
        gst-plugins-ugly
        gstreamer
        # keep-sorted end
      ];
  in {
    packages.lutris = buildFHSEnv {
      pname = "lutris";
      inherit (pkgs.lutris-unwrapped) version;
      runScript = "lutris";
      multiArch = true;

      targetPkgs = pkgs:
        (with pkgs; [
          # keep-sorted start
          fuse
          glib-networking
          gnugrep
          gnused
          libnghttp2
          lutris-unwrapped
          opencl-headers
          p7zip
          perl
          psmisc
          which
          xrandr
          # keep-sorted end
        ])
        ++ qt5Deps pkgs
        ++ qt6Deps pkgs
        ++ gnomeDeps pkgs
        ++ [pkgs.steam];

      multiPkgs = pkgs: let
        originalPkgs =
          (with pkgs; [
            # keep-sorted start
            SDL
            SDL2
            alsa-lib
            bash
            cabextract
            cairo
            coreutils
            cups
            curl
            dbus
            freetype
            fribidi
            gcc
            giflib
            glib
            gnutls
            graphite2
            gtk2
            gtk3
            harfbuzz
            keyutils
            lcms2
            libGLU
            libaio
            libao
            libass
            libbsd
            libcap
            libcdio
            libevdev
            libgcrypt
            libglvnd
            libgphoto2
            libjack2
            libjpeg
            libkrb5
            libmad
            libmpeg2
            libogg
            libopus
            libpcap
            libpng
            libpulseaudio
            libsamplerate
            libselinux
            libsndfile
            libtheora
            libtiff
            libusb1
            libv4l
            libva
            libvorbis
            libxkbcommon
            libxml2
            libxslt
            libzip
            mpg123
            ncurses
            ocl-icd
            openldap
            p11-kit
            pango
            readline
            samba4
            sane-backends
            sqlite
            udev
            unixodbc
            unzip
            util-linux
            vulkan-loader
            wayland
            xdg-utils
            zip
            zlib
            zziplib
            # keep-sorted end
          ])
          ++ xorgDeps pkgs
          ++ gstreamerDeps pkgs;

        # Keep Lutris building while upstream openldap checks fail here.
        customLdap = pkgs.openldap.overrideAttrs (_: {doCheck = false;});
      in
        filter (p: (p.pname or "") != "openldap") originalPkgs ++ [customLdap];

      extraInstallCommands = ''
        mkdir -p $out/share
        ln -sf ${pkgs.lutris-unwrapped}/share/applications $out/share
        ln -sf ${pkgs.lutris-unwrapped}/share/icons $out/share
      '';

      # Allows for some gui applications to share IPC
      # This fixes certain issues where they don't render correctly
      unshareIpc = false;

      # Some applications such as Natron need access to MIT-SHM or other
      # Shared memory mechanisms. Unsharing the pid namespace
      # Breaks the ability for application to reference shared memory.
      unsharePid = false;

      meta = {
        inherit
          (pkgs.lutris-unwrapped.meta)
          homepage
          description
          platforms
          license
          maintainers
          broken
          ;

        mainProgram = "lutris";
      };
    };
  };
}

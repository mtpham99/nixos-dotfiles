# default.nix (mpv)

{ pkgs, config,... }:

{
  # symlink shaders
  xdg.configFile."mpv/shaders".source = ./shaders;

  programs.mpv = {
    enable = true;

    scripts = with pkgs.mpvScripts; [
    ];

    scriptOpts = {
    };

    profiles = {
      big-cache = {
        cache = true;
        demuxer-max-bytes = "512MiB";
        demuxer-readahead-secs = 20;
      };
      debanding = {
        deband = true;
        deband-iterations = 4;
        deband-threshold = 35;
        deband-range = 16;
        deband-grain = 0;
      };
      hdr = {
        gpu-api = "vulkan"; # vulkan opengl
        gpu-context = "waylandvk";
        target-colorspace-hint = true;
        target-contrast = "inf"; # ~1000 (IPS) ~3000-5000 (VA) inf (OLED)
        target-peak = "auto"; # displays max nits
      };
      experimental-quality = {
        glsl-shader = [
          "${config.xdg.configHome}/mpv/shaders/FSRCNNX_x2_8-0-4-1.glsl"
          "${config.xdg.configHome}/mpv/shaders/SSimDownscaler.glsl"
          "${config.xdg.configHome}/mpv/shaders/KrigBilateral.glsl"
        ];
      };
      ultra-quality = {
        glsl-shader = [
          "${config.xdg.configHome}/mpv/shaders/nnedi3-nns128-win8x4.hook"
        ];
      };
    };

    defaultProfiles = [ "high-quality" ];

    config = {
      # general video/hardware
      hwdec = "auto-safe"; # auto(-copy;-safe) nvdec(-copy) vaapi(-copy) vulkan(-copy)
      vo = "gpu-next";
      gpu-api = "opengl"; # vulkan opengl
      gpu-context = "wayland"; # waylandvk wayland

      # scaling
      scale = "ewa_lanczossharp";
      dscale = "mitchell";
      cscale = "ewa_lanczossharp";
      linear-downscaling = false;

      # tone-mapping
      tone-mapping = "st2094-40"; # bt.2390 vs bt.2446a (hdr->sdr) ; st2094-40 (hdr10+->sdr)
      target-peak = "auto"; # nits
      target-contrast = "inf"; # ~1000 (IPS) ~3000-5000 (VA) inf (OLED)

      # anti-ringing
      scale-antiring = 0.7;
      dscale-antiring = 0.7;
      cscale-antiring = 0.7;

      # dither
      dither-depth = "auto"; # "auto" 8 10
      dither = "fruit"; # fruit (8bit) ordered (10bit)

      # deinterlace
      deinterlace = false;

      # interpolation
      # video-sync = "display-resample";
      # interpolation = true;
      # tscale = "oversample";

      # language priority
      alang = "eng,en,jp,ja"; # audio
      slang = "eng,en,jp,ja"; # subtitles

      # audio
      volume = 80;
      volume-max = 150;
      audio-file-auto = "fuzzy";
      audio-exclusive = true;
      audio-channels = "auto"; # auto(-safe) (e.g. stereo,5.1,7.2)
      # audio-delay = "+0.084";

      # subtitles
      demuxer-mkv-subtitle-preroll = true; # show subtitles while seeking
      subs-with-matching-audio = "no";
      blend-subtitles = true;
      sub-fix-timing = true;
      sub-auto = "fuzzy";
      sub-gauss = 1.0;
      sub-gray = true;
      # sub-font = ;
      # sub-font-size = ;
      sub-blur = 0.1;
      sub-color = "1.0/1.0/1.0/1.0"; # rgba
      sub-border-color = "0.0/0.0/0.0/1.0"; # rgba
      sub-border-size = 3.4;
      # sub-margin-x = ;
      # sub-margin-y = ;
      sub-shadow-color = "0.0/0.0/0.0/0.4"; # rgba
      sub-shadow-offset = 0.5;

      # general player options
      hidpi-window-scale = false;
      keep-open = true;
      save-position-on-quit = true;
      force-seekable = true;
      cursor-autohide = 1000; # ms

      # screenshots
      screenshot-format = "png";
      screenshot-high-bit-depth = true;
      screenshot-png-compression = 1; # 1 (low compression) - 9 (max compression)
      screenshot-jpeg-quality = 100; # 0 (low quality) - 100 (max quality)
      screenshot-dir = "${config.xdg.userDirs.pictures}/screenshots/mpv";
      # screenshot-template = "%f-%wH.%wM.%wS.%wT-#%#00n";
    };
  };


  # edit `exec` of desktop entry to always run with dgpu
  xdg.desktopEntries."mpv" = {
    type = "Application";
    name = "mpv Media Player";
    genericName = "Multimedia player";
    comment = "Play movies and songs";
    icon = "mpv";
    exec = "env __NV_PRIME_RENDER_OFFLOAD=1 __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only mpv --player-operation-mode=pseudo-gui -- %U";
    terminal = false;
    categories = [
      "AudioVideo"
      "Audio"
      "Video"
      "Player"
      "TV"
    ];
    mimeType = [
      "application/ogg"
      "application/x-ogg"
      "application/mxf"
      "application/sdp"
      "application/smil"
      "application/x-smil"
      "application/streamingmedia"
      "application/x-streamingmedia"
      "application/vnd.rn-realmedia"
      "application/vnd.rn-realmedia-vbr"
      "audio/aac"
      "audio/x-aac"
      "audio/vnd.dolby.heaac.1"
      "audio/vnd.dolby.heaac.2"
      "audio/aiff"
      "audio/x-aiff"
      "audio/m4a"
      "audio/x-m4a"
      "application/x-extension-m4a"
      "audio/mp1"
      "audio/x-mp1"
      "audio/mp2"
      "audio/x-mp2"
      "audio/mp3"
      "audio/x-mp3"
      "audio/mpeg"
      "audio/mpeg2"
      "audio/mpeg3"
      "audio/mpegurl"
      "audio/x-mpegurl"
      "audio/mpg"
      "audio/x-mpg"
      "audio/rn-mpeg"
      "audio/musepack"
      "audio/x-musepack"
      "audio/ogg"
      "audio/scpls"
      "audio/x-scpls"
      "audio/vnd.rn-realaudio"
      "audio/wav"
      "audio/x-pn-wav"
      "audio/x-pn-windows-pcm"
      "audio/x-realaudio"
      "audio/x-pn-realaudio"
      "audio/x-ms-wma"
      "audio/x-pls"
      "audio/x-wav"
      "video/mpeg"
      "video/x-mpeg2"
      "video/x-mpeg3"
      "video/mp4v-es"
      "video/x-m4v"
      "video/mp4"
      "application/x-extension-mp4"
      "video/divx"
      "video/vnd.divx"
      "video/msvideo"
      "video/x-msvideo"
      "video/ogg"
      "video/quicktime"
      "video/vnd.rn-realvideo"
      "video/x-ms-afs"
      "video/x-ms-asf"
      "audio/x-ms-asf"
      "application/vnd.ms-asf"
      "video/x-ms-wmv"
      "video/x-ms-wmx"
      "video/x-ms-wvxvideo"
      "video/x-avi"
      "video/avi"
      "video/x-flic"
      "video/fli"
      "video/x-flc"
      "video/flv"
      "video/x-flv"
      "video/x-theora"
      "video/x-theora+ogg"
      "video/x-matroska"
      "video/mkv"
      "audio/x-matroska"
      "application/x-matroska"
      "video/webm"
      "audio/webm"
      "audio/vorbis"
      "audio/x-vorbis"
      "audio/x-vorbis+ogg"
      "video/x-ogm"
      "video/x-ogm+ogg"
      "application/x-ogm"
      "application/x-ogm-audio"
      "application/x-ogm-video"
      "application/x-shorten"
      "audio/x-shorten"
      "audio/x-ape"
      "audio/x-wavpack"
      "audio/x-tta"
      "audio/AMR"
      "audio/ac3"
      "audio/eac3"
      "audio/amr-wb"
      "video/mp2t"
      "audio/flac"
      "audio/mp4"
      "application/x-mpegurl"
      "video/vnd.mpegurl"
      "application/vnd.apple.mpegurl"
      "audio/x-pn-au"
      "video/3gp"
      "video/3gpp"
      "video/3gpp2"
      "audio/3gpp"
      "audio/3gpp2"
      "video/dv"
      "audio/dv"
      "audio/opus"
      "audio/vnd.dts"
      "audio/vnd.dts.hd"
      "audio/x-adpcm"
      "application/x-cue"
      "audio/m3u"
    ];
  };
}

{
  flake.modules.homeManager.zen = {
    # keep-sorted start
    config,
    lib,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatMapAttrs
      isAttrs
      mkEnableOption
      mkOption
      types
      # keep-sorted end
      ;
    inherit
      (vars)
      # keep-sorted start
      countryCode
      groundDomain
      # keep-sorted end
      ;
  in {
    options.programs.zen-browser.profiles = mkOption {
      type = types.attrsOf (types.submodule {
        options.preferences = {
          # keep-sorted start block=yes newline_separated=yes
          commitSpace = mkOption {
            description = "Memory threshold (in MiB) at which tabs are unloaded when available commit space is low";

            type = types.int;
          };

          travel.enable = mkEnableOption "Enable travel specific preferences.";
          # keep-sorted end
        };
      });
    };

    config.programs.zen-browser.profiles.default.settings = let
      cfg = config.programs.zen-browser.profiles.default.preferences;

      flattenSettings = prefix:
        concatMapAttrs (name: value: let
          key =
            if prefix == ""
            then name
            else "${prefix}.${name}";
        in
          if isAttrs value
          then flattenSettings key value
          else {${key} = value;});
    in
      flattenSettings "" {
        # keep-sorted start
        captivedetect.canonicalURL = " ";
        content.notify.interval = 100000;
        devtools.selfxss.count = 0;
        doh-rollout.home-region = countryCode;
        lightweightThemes.getMoreURL = " ";
        pdfjs.sidebarViewOnLoad = 0;
        plain_text.wrap_long_lines = false;
        reader.parse-on-load.enabled = false;
        ui.key.menuAccessKey = 0;
        # keep-sorted end

        # keep-sorted start block=yes newline_separated=yes
        browser = {
          # keep-sorted start
          aboutConfig.showWarning = false;
          bookmarks.max_backups = 1;
          download.always_ask_before_handling_new_types = false;
          link.open_newwindow.restriction = 0;
          promo.focus.enabled = false;
          theme.dark-private-windows = false;
          topsites.useRemoteSetting = false;
          vpn_promo.enabled = false;
          warnOnQuitShortcut = false;
          # keep-sorted end

          # keep-sorted start
          low_commit_space_threshold_mb = cfg.commitSpace;
          low_commit_space_threshold_percent = 20;
          # keep-sorted end

          # keep-sorted start block=yes newline_separated=yes
          cache = {
            # keep-sorted start
            frecency_half_life_hours = 12;
            max_shutdown_io_lag = 16;
            # keep-sorted end

            # keep-sorted start block=yes newline_separated=yes
            disk = {
              smart_size.enabled = false;

              # keep-sorted start
              capacity = 8192000;
              metadata_memory_limit = 15360;
              # keep-sorted end
            };

            memory = {
              # keep-sorted start
              capacity = 131072;
              max_entry_size = 327680;
              # keep-sorted end
            };
            # keep-sorted end
          };

          contentblocking = {
            # keep-sorted start block=yes newline_separated=yes
            category = "strict";

            report = {
              # keep-sorted start
              hide_vpn_banner = true;
              lockwise.enabled = false;
              # keep-sorted end
            };
            # keep-sorted end
          };

          newtabpage.activity-stream = {
            # keep-sorted start
            default.sites = " ";
            feeds.section.topstories.options = "{\"hidden\":true}";
            # keep-sorted end

            # keep-sorted start block=yes newline_separated=yes
            newtabWallpapers.v2.enabled = false;

            section.highlights = {
              # keep-sorted start
              includeDownloads = false;
              includeVisited = false;
              # keep-sorted end
            };
            # keep-sorted end
          };

          region = {
            # keep-sorted start
            network.url = " ";
            update.enabled = false;
            # keep-sorted end
          };

          safebrowsing = {
            # keep-sorted start
            blockedURIs.enabled = false;
            malware.enabled = false;
            phishing.enabled = false;
            # keep-sorted end

            # keep-sorted start block=yes newline_separated=yes
            downloads = {
              # keep-sorted start
              dangerous.enabled = false;
              enabled = false;
              # keep-sorted end

              remote = {
                enabled = false;

                # keep-sorted start
                block_dangerous = false;
                block_dangerous_host = false;
                block_potentially_unwanted = false;
                block_uncommon = false;
                # keep-sorted end

                url = " ";
              };
            };

            provider = {
              # keep-sorted start block=yes newline_separated=yes
              google = {
                # keep-sorted start
                gethashURL = " ";
                reportURL = " ";
                updateURL = " ";
                # keep-sorted end
              };

              google4 = {
                # keep-sorted start
                dataSharingURL = " ";
                gethashURL = " ";
                updateURL = " ";
                # keep-sorted end
              };
              # keep-sorted end
            };
            # keep-sorted end
          };

          search = {
            # keep-sorted start
            separatePrivateDefault.ui.enabled = false;
            suggest.enabled.private = true;
            # keep-sorted end

            serpEventTelemetryCategorization = {
              # keep-sorted start
              enabled = false;
              regionEnabled = false;
              # keep-sorted end
            };
          };

          startup = {
            homepage = "https://${groundDomain}";
            page = 1;
          };

          tabs = {
            # keep-sorted start
            min_inactive_duration_before_unload = 300000;
            searchclipboardfor.middleclick = false;
            unloadOnLowMemory = true;
            # keep-sorted end
          };

          urlbar = {
            # keep-sorted start
            addons.featureGate = true;
            autoFill.adaptiveHistory.enabled = true;
            # keep-sorted end

            suggest = {
              # keep-sorted start
              clipboard = false;
              fakespot = false;
              quickactions = false;
              trending = false;
              weather = false;
              yelp = false;
              # keep-sorted end
            };
          };
          # keep-sorted end
        };

        dom = {
          # keep-sorted start
          disable_window_move_resize = true;
          text_fragments.create_text_fragment.enabled = true;
          # keep-sorted end

          # keep-sorted start block=yes newline_separated=yes
          security = {
            # keep-sorted start
            https_only_mode.upgrade_onion = true;
            https_only_mode_pbm = true;
            # keep-sorted end
          };

          timeout = {
            # keep-sorted start
            budget_throttling_max_delay = 0;
            throttling_delay = 40;
            # keep-sorted end
          };

          webgpu = {
            # keep-sorted start
            enabled = true;
            service-workers.enabled = true;
            # keep-sorted end
          };

          # keep-sorted end
        };

        extensions = {
          # keep-sorted start
          autoDisableScopes = 0;
          enabledScopes = 7;
          postDownloadThirdPartyPrompt = false;
          # keep-sorted end

          # keep-sorted start
          webcompat-reporter.newIssueEndpoint = " ";
          webextensions.restrictedDomains = " ";
          # keep-sorted end

          pocket = {
            # keep-sorted start
            quarantinedDomains.enabled = false;
            showHome = false;
            # keep-sorted end

            # keep-sorted start
            api = " ";
            oAuthConsumerKey = " ";
            site = " ";
            # keep-sorted end
          };
        };

        general = {
          # keep-sorted start
          autoScroll = false;
          useragent.compatMode.firefox = true;
          # keep-sorted end
        };

        gfx = {
          # keep-sorted start
          content.skia-font-cache-size = 80;
          webgpu.ignore-blocklist = true;
          # keep-sorted end

          # keep-sorted start block=yes newline_separated=yes
          canvas.accelerated = {
            # keep-sorted start
            cache-items = 32768;
            cache-size = 4096;
            # keep-sorted end
          };

          webrender = {
            # keep-sorted start
            all = true;
            precache-shaders = true;
            program-binary-disk = true;
            quality.force-subpixel-aa-where-possible = true;
            # keep-sorted end

            "compositor" = true;
          };

          # keep-sorted end
        };

        identity.sync.tokenserver.uri = "https://firefox-sync.${groundDomain}/1.0/sync/1.5";

        image = {
          # keep-sorted start block=yes newline_separated=yes
          cache.size = 10485760;

          mem = {
            # keep-sorted start
            decode_bytes_at_a_time = 65536;
            shared.unmap.min_expiration_ms = 120000;
            # keep-sorted end
          };
          # keep-sorted end
        };

        javascript.options = {
          # keep-sorted start
          baselinejit.threshold = 50;
          concurrent_multiprocess_gcs.cpu_divisor = 8;
          ion.threshold = 5000;
          # keep-sorted end
        };

        layers = {
          acceleration.force-enabled = true;
          mlgpu.enabled = true;

          gpu-process = {
            enabled = true;
            force-enabled = true;
          };
        };

        layout = {
          # keep-sorted start block=yes newline_separated=yes
          css = {
            # keep-sorted start
            grid-template-masonry-value.enabled = true;
            moz-document.content.enabled = true;
            # keep-sorted end
          };

          spellcheckDefault = 2;
          # keep-sorted end
        };

        media = {
          # keep-sorted start
          autoplay.default = 5;
          hardware-video-decoding.force-enabled = true;
          # keep-sorted end

          # keep-sorted start
          gpu-process-decoder = true;
          gpu-process-encoder = true;
          # keep-sorted end

          # keep-sorted start
          cache_readahead_limit = 7200;
          cache_resume_threshold = 3600;
          # keep-sorted end

          # keep-sorted start
          memory_cache_max_size = 1048576;
          memory_caches_combined_limit_kb = 3145728;
          memory_caches_combined_limit_pc_sysmem = 10;
          # keep-sorted end
        };

        network = {
          # keep-sorted start
          captive-portal-service.enabled = cfg.travel.enable;
          connectivity-service.enabled = false;
          # keep-sorted end

          # keep-sorted start
          auth.subresource-http-auth-allow = 1;
          ssl_tokens_cache_capacity = 32768;
          trr.mode = 2;
          # keep-sorted end

          # keep-sorted start
          dnsCacheEntries = 1000;
          dnsCacheExpiration = 3600;
          dnsCacheExpirationGracePeriod = 240;
          # keep-sorted end

          # keep-sorted start block=yes newline_separated=yes
          buffer.cache = {
            # keep-sorted start
            count = 48;
            size = 65535;
            # keep-sorted end
          };

          http = {
            referer.XOriginTrimmingPolicy = 2;

            # keep-sorted start
            max-connections = 1800;
            max-persistent-connections-per-proxy = 48;
            max-persistent-connections-per-server = 10;
            max-urgent-start-excessive-connections-per-host = 5;
            # keep-sorted end

            pacing.requests = {
              enabled = false;

              # keep-sorted start
              burst = 14;
              min-parallelism = 10;
              # keep-sorted end
            };
            # keep-sorted end
          };

          predictor = {
            enable-prefetch = true;

            # keep-sorted start
            max-resources-per-entry = 250;
            max-uri-length = 1000;
            # keep-sorted end

            # keep-sorted start
            preconnect-min-confidence = 20;
            preresolve-min-confidence = 10;
            # keep-sorted end

            # keep-sorted start
            prefetch-force-valid-for = 3600;
            prefetch-min-confidence = 30;
            prefetch-rolling-load-count = 120;
            # keep-sorted end
          };
        };

        nglayout.initialpaint = {
          # keep-sorted start
          delay = 0;
          delay_in_oopif = 0;
          # keep-sorted end
        };

        permissions = {
          # keep-sorted start block=yes newline_separated=yes
          default = {
            # keep-sorted start
            desktop-notification = 2;
            xr = 2;
            # keep-sorted end
          };

          manager.defaultsUrl = " ";
          # keep-sorted end
        };

        privacy = {
          # keep-sorted start
          donottrackheader.enabled = true;
          globalprivacycontrol.enabled = true;
          # keep-sorted end
        };

        security = {
          # keep-sorted start block=yes newline_separated=yes
          OCSP = {
            require = true;
            enabled = 2;
          };

          cert_pinning.enforcement_level = 2;

          ssl = {
            # keep-sorted start
            require_safe_negotiation = true;
            treat_unsafe_negotiation_as_broken = true;
            # keep-sorted end
          };
          # keep-sorted end
        };

        signon = {
          # keep-sorted start
          autofillForms = false;
          formlessCapture.enabled = false;
          management.page.breach-alerts.enabled = false;
          # keep-sorted end
        };

        toolkit.telemetry = {
          # keep-sorted start
          cachedClientID = " ";
          server_owner = " ";
          # keep-sorted end
        };

        widget = {
          # keep-sorted start block=yes newline_separated=yes
          gtk.non-native-titlebar-buttons.enabled = true;

          use-xdg-desktop-portal = {
            # keep-sorted start
            file-picker = 1;
            mime-handler = 1;
            open-uri = 1;
            # keep-sorted end
          };
          # keep-sorted end
        };

        zen = {
          # keep-sorted start
          view.experimental-no-window-controls = true;
          watermark.enabled = false;
          welcome-screen.seen = true;
          # keep-sorted end

          # keep-sorted start block=yes newline_separated=yes
          urlbar = {
            # keep-sorted start
            behavior = "float";
            show-pip-button = true;
            # keep-sorted end
          };

          workspaces = {
            # keep-sorted start
            continue-where-left-off = true;
            separate-essentials = false;
            # keep-sorted end
          };
          # keep-sorted end
        };
        # keep-sorted end
      };
  };
}

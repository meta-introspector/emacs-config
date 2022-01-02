{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus/v1.3.1";

    home-manager.url = "github:nix-community/home-manager";

    # Emacs
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    org-babel.url = "github:akirak/nix-org-babel";
    twist.url = "github:akirak/emacs-twist/devel";
    emacs-inventories.url = "path:./emacs/inventories";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils-plus
    , utils
    , home-manager
    , ...
    } @ inputs:
    let
      inherit (builtins) removeAttrs;
      mkApp = utils.lib.mkApp;
      # pkgs = self.pkgs.x86_64-linux.nixpkgs;
    in
    flake-utils-plus.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [ "x86_64-linux" ];

      channelsConfig = {
        allowBroken = false;
      };

      sharedOverlays = [
        inputs.emacs-overlay.overlay
        inputs.org-babel.overlay
        inputs.twist.overlay
        (import ./emacs/overlay.nix {
          inherit (inputs) twist org-babel;
          inherit (inputs.emacs-inventories.lib) inventories;
        })
      ];

      # Nixpkgs flake reference to be used in the configuration.
      # Autogenerated from `inputs` by default.
      # channels.<name> = {}

      hostsDefaults = {
        system = "x86_64-linux";

        # Default modules to be passed to all hosts.
        modules = [
          ./nixos/modules/defaults.nix
        ];

        # channelName = "unstable";
      };

      #############
      ### hosts ###
      #############

      hosts.container = {
        extraArgs = {
          home = import ./hm/home.nix;
        };

        modules =
          [
            {
              boot.isContainer = true;
              networking.useDHCP = false;
              networking.firewall.allowedTCPPorts = [ ];

              services.openssh = {
                enable = true;
              };
            }
            home-manager.nixosModules.home-manager
            ./nixos/modules/default-user.nix
          ];
      };

      #############################
      ### flake outputs builder ###
      #############################

      outputsBuilder = channels:
        let
          inherit (channels.nixpkgs) emacsConfigurations;
          emacs-full = emacsConfigurations.full;
          emacs-basic = emacsConfigurations.basic;
          emacs-compat = emacsConfigurations.compat;

          emacsSandbox = channels.nixpkgs.callPackage ./sandbox/emacs.nix { };

          useDoomTheme = themeName: [
            "--eval"
            "(when init-file-user (require 'doom-themes) (load-theme '${themeName} t))"
          ];
        in
        {
          packages = {
            inherit emacs-full;
            # Add more variants of the full profile later
            emacs = emacsSandbox emacs-basic {
              emacsArguments = useDoomTheme "doom-tomorrow-night";
            };
            emacs-compat = emacsSandbox emacs-compat {
              # emacsArguments = useDoomTheme "doom-tomorrow-night";
            };
          };

          apps =
            {
              lock = mkApp {
                drv = emacs-full.lock.writeToDir "emacs/sources";
              };
              sync = mkApp {
                drv = emacs-full.sync.writeToDir "emacs/sources";
              };
              update = mkApp {
                drv = emacs-full.update.writeToDir "emacs/sources";
              };
            };
        };

      #########################################################
      ### All other properties are passed down to the flake ###
      #########################################################

      # checks.x86_64-linux.someCheck = pkgs.hello;
      # packages.x86_64-linux.somePackage = pkgs.hello;
      # overlay = import ./overlays;
      # abc = 132;
    };
}

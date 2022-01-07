{ twist
, org-babel
, gnu-elpa
, melpa
, epkgs
, emacs
}:
final: prev:
let
  inherit (prev) tangleOrgBabelFile emacsPgtkGcc emacsTwist;
  org = org-babel.lib;
  inherit (twist.lib { inherit (prev) lib; }) parseSetup;

  initFile = tangleOrgBabelFile "init.el" ./emacs-config.org {
    processLines = org.excludeHeadlines (org.tag "ARCHIVE");
  };

  compatEl = builtins.path {
    name = "compat.el";
    path = ./compat.el;
  };

  extraConfigFile = ./extras.org;

  extraFile = f: tangleOrgBabelFile "extra-init.el" ./extras.org {
    processLines = lines: prev.lib.pipe lines [
      (org.excludeHeadlines (org.tag "ARCHIVE"))
      f
    ];
  };

  releaseVersions = {
    elispTreeSitterVersion = "0.16.1";
    elispTreeSitterLangsVersion = "0.10.13";
  };

  makeEmacsConfiguration = initFiles: (emacsTwist {
    inventories = [
      {
        type = "melpa";
        path = ./recipes;
      }
      {
        type = "elpa-core";
        path = gnu-elpa.outPath + "/elpa-packages";
        src = emacs.outPath;
      }
      {
        name = "melpa";
        type = "melpa";
        path = melpa.outPath + "/recipes";
      }
      {
        name = "gnu";
        type = "archive";
        url = "https://elpa.gnu.org/packages/";
      }
      {
        name = "nongnu";
        type = "archive";
        url = "https://elpa.nongnu.org/nongnu/";
      }
      {
        name = "emacsmirror";
        type = "gitmodules";
        path = epkgs.outPath + "/.gitmodules";
      }
    ];
    inherit initFiles;
    extraPackages = [
      "setup"
    ];
    initParser = parseSetup { };
    emacsPackage = emacsPgtkGcc.overrideAttrs (_: { version = "29.0.50"; });
    lockDir = ./lock;
    inputOverrides = import ./inputs.nix releaseVersions;
  }).overrideScope' (self: super: {
    elispPackages = super.elispPackages.overrideScope'
      (import ./overrides.nix releaseVersions {
        pkgs = final;
        inherit (prev) system;
        inherit (self) emacs;
      });
  });
in
{
  emacsConfigurations = {
    # Used to generate lock files
    full = makeEmacsConfiguration [
      initFile
      compatEl
      (extraFile prev.lib.id)
    ];
    basic = makeEmacsConfiguration [
      initFile
    ];
    compat = makeEmacsConfiguration [
      initFile
      compatEl
    ];
    beancount = makeEmacsConfiguration [
      initFile
      compatEl
      (extraFile (org.selectHeadlines (org.headlineText "beancount")))
    ];
  };
}

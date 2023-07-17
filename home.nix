{ config, pkgs, ... }:

let
  username = "feser";
  homeDirectory = "/Users/${username}";
  emacs = (pkgs.emacsPackagesFor pkgs.emacs-git).emacsWithPackages
    (epkgs: with epkgs; [ treesit-grammars.with-all-grammars ]);
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    (python3.withPackages (p: with p; [ tqdm requests z3 ]))
    aspell
    aspellDicts.en
    emacs
    fswatch
    git
    htop
    ltex-ls
    nix-tree
    nixfmt
    nodejs
    ripgrep
    rsync
    sshpass
    tectonic
    z3
  ];

  home.sessionVariables = {
    VISUAL = "emacs";
    EDITOR = "emacs";
  };

  home.file.".aspell.conf".text = ''
    data-dir ${homeDirectory}/.nix-profile/lib/aspell
  '';

  programs.git = {
    enable = true;
    package = pkgs.gitSVN;
    userName = "Jack Feser";
    userEmail = "jack.feser@gmail.com";
    extraConfig = {
      credential = {
        "https://git.overleaf.com" = { username = "jack.feser@gmail.com"; };
      };
    };
  };

  programs.fish = {
    enable = true;
    functions = {
      fish_prompt = {
        body = ''
          	test $SSH_TTY
            and printf (set_color red)$USER(set_color brwhite)'@'(set_color yellow)(prompt_hostname)' '
            test $USER = 'root'
            and echo (set_color red)"#"
            echo -n (set_color cyan)(prompt_pwd) '> '
        '';
      };
    };
    shellInit = ''
      ### Add nix binary paths to the PATH
      # Perhaps someday will be fixed in nix or nix-darwin itself
      # See https://github.com/LnL7/nix-darwin/issues/122
      if test (uname) = Darwin
         fish_add_path --prepend --global "$HOME/.nix-profile/bin" /nix/var/nix/profiles/default/bin /run/current-system/sw/bin
      end

      set fish_greeting ""
    '';
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = { identityFile = "~/.ssh/id_rsa"; };

      "jump.csail.mit.edu" = {
        extraOptions = { "VerifyHostKeyDNS" = "yes"; };
        user = "feser";
      };

      "*.csail.mit.edu !jump.csail.mit.edu 128.52.* 128.30.* 128.31.*" = {
        proxyJump = "jump.csail.mit.edu";
        user = "feser";
        extraOptions = {
          "GSSAPIAuthentication" = "yes";
          "GSSAPIDelegateCredentials" = "yes";
        };
      };

      "jack-workstation" = { user = "feser"; };
      "jack-storage" = { user = "jack"; };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.opam.enable = true;
}

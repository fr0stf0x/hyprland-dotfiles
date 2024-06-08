{pkgs, ...}: let
  dotfiles = "$HOME/dev/hyprland-dotfiles";
  symlink = pkgs.writeShellScript "symlink" ''
    if [[ "$1" == "-r" ]]; then
      rm -rf "$HOME/.config/ags"
    fi

    if [[ "$1" == "-a" ]]; then
      rm -rf "$HOME/.config/ags"

      ln -s "${dotfiles}/ags" "$HOME/.config/ags"
    fi
  '';
  nx-switch = pkgs.writeShellScriptBin "nx-switch" ''
    ${symlink} -r
    ${
      if pkgs.stdenv.isDarwin
      then "darwin-rebuild switch --flake . --impure $@"
      else "sudo nixos-rebuild switch --flake . --impure $@"
    }
    ${symlink} -a
  '';
  nx-boot = pkgs.writeShellScriptBin "nx-boot" ''
    ${symlink} -r
    sudo nixos-rebuild boot --flake . --impure $@
    ${symlink} -a
  '';
  nx-test = pkgs.writeShellScriptBin "nx-test" ''
    ${symlink} -r
    sudo nixos-rebuild test --flake . --impure $@
    ${symlink} -a
  '';
in {
  home.packages = [nx-switch nx-boot nx-test];
}

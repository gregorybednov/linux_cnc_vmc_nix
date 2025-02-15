{
  description = "Linux CNC VMC - среда моделирования";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      simintech = pkgs.stdenv.mkDerivation rec {
        pname = "cnc_vmc_sim";
        version = "2.23.13";
        src = builtins.fetchTarball {
          url = "http://kafpi.local/linux_cnc_vmc_share.tar.xz"; # подставьте сюда свой адрес дистрибутива
          sha256 = "";
        };

        fhsEnv = pkgs.buildFHSEnv {
          name = "${pname}-fhs-env";
          targetPkgs =
            p: with p; [
              eudev.out
              libGL.out
              openal.out
              xorg.libX11.out
            ];
          runScript = "${src}/bin/${pname}";
        };

        desktopItem = pkgs.makeDesktopItem {
          name = "${pname}";
          exec = "${pname}";
          desktopName = "CNC VMC Simulator";
          categories = [ "Development" ];
          icon = "${pname}";
          terminal = false;
          startupNotify = false;
        };

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          mkdir -p $out/share/applications
          mkdir -p $out/share/icons
          cp ${src}/icon.png $out/share/icons/${pname}.png
          cp ${fhsEnv}/bin/${pname}-fhs-env $out/bin/${pname}
          cp ${desktopItem}/share/applications/*.desktop $out/share/applications
          runHook postInstall
        '';
      };
    in
    {
      packages.x86_64-linux.cnc_vmc_sim = cnc_vmc_sim;
      defaultPackage.x86_64-linux = cnc_vmc_sim;
    };
}

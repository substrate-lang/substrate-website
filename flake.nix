{
  description = "substrate-website: substrate-lang.com, written in substrate";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      chromium = pkgs:
        if pkgs.stdenv.isLinux then pkgs.chromium
        else pkgs.runCommand "chromium" {
          browsers = pkgs.playwright-driver.browsers-chromium.override { withFfmpeg = false; };
        } ''
          app="$(find -L "$browsers" -maxdepth 3 -name '*.app' | head -1)"
          [ -n "$app" ] || { echo "no application bundle in $browsers" >&2; exit 1; }
          mkdir -p "$out/bin"
          { echo '#!${pkgs.runtimeShell}'
            echo "exec \"$app/Contents/MacOS/$(basename "$app" .app)\" \"\$@\""
          } > "$out/bin/chromium"
          chmod +x "$out/bin/chromium"
        '';
      # substrate's npm release, with no toolchains from substrate upgrade in place of it
      substrate = pkgs: pkgs.stdenvNoCC.mkDerivation {
        pname = "substrate";
        version = "0.11.2";
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/substrate-lang/-/substrate-lang-0.11.2.tgz";
          hash = "sha512-+yAsX0KEPsW1bbyPbpH6QMghQNiKrHd1GEI7U/m/EgdNw58m8CMU8APquycgcJbC4UdMHykBH/VjMohWWp642A==";
        };
        nativeBuildInputs = [ pkgs.makeWrapper ];
        installPhase = ''
          mkdir -p $out/lib/substrate $out/lib/home $out/bin
          cp -r . $out/lib/substrate
          makeWrapper ${pkgs.nodejs}/bin/node $out/bin/substrate \
            --add-flags $out/lib/substrate/bin/substrate.mjs --set SUBSTRATE_HOME $out/lib/home
        '';
      };
    in {
      devShells = forAll (pkgs: {
        default = pkgs.mkShell {
          packages = [
            (substrate pkgs)
            pkgs.nodejs        # V8: substrate's host, and the browser tests' driver
            (chromium pkgs)    # the headless browser of the browser tests (above)
          ];
        };
        # WebKit, Safari's engine, with Playwright to drive it: nix develop .#webkit
        webkit = pkgs.mkShell {
          packages = [ (substrate pkgs) pkgs.nodejs ];
          PLAYWRIGHT_CORE = "${pkgs.playwright-driver}";
          PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers.override {
            withChromium = false; withChromiumHeadlessShell = false; withFirefox = false; withFfmpeg = false;
          };
        };
      });
    };
}

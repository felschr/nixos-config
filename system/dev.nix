{ ... }:

{
  # running binaries for other architectures (e.g. nixpkgs-review for
  # non-native systems)
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
    "wasm64-wasi"
    "wasm32-wasi"
  ];
}

{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule rec {
  pname = "ecoflow_exporter";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "tess1o";
    repo = "go-ecoflow-exporter";
    tag = "${version}";
    hash = "sha256-VCzMItYgnuDXDYdrk/ojzqUE2Fjr7KWGNnLhoQ+ZPYs=";
  };

  vendorHash = "sha256-UbV6V06zxXMTd0v+rDPGoMFn9X5mMCiX41g49IGnoT8=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/tess1o/go-ecoflow-exporter/releases/tag/${version}";
    homepage = "https://github.com/tess1o/go-ecoflow-exporter";
    description = "Ecoflow solar battery prometheus mqtt metric exporter in golan via rest api";
    license = lib.licenses.mit;
    mainProgram = "go-ecoflow-exporter";
    maintainers = with lib.maintainers; [ paepcke ];
  };
}

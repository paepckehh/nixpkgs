{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "subspace-ng";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "paepckehh";
    repo = "${finalAttrs.pname}";
    tag = "v${finalAttrs.version}";
    hash = "";
  };

  ldflags = [
    "-s"
    "-w"
    # "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
    # "-X github.com/prometheus/common/version.Revision=${finalAttrs.src.rev}"
  ];

  vendorHash = "";

  passthru.updateScript = nix-update-script {};

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/subspace-ng";
  versionCheckProgramArg = "--version";

  meta = {
    changelog = "https://github.com/paepckehh/${finalAttrs.pname}/releases/tag/v${finalAttrs.version}";
    homepage = "https://paepcke.de/paepckehh/${finalAttrs.pname}";
    description = "WireGuard VPN server GUI";
    license = lib.licenses.mit;
    mainProgram = "${finalAttrs.pname}";
    maintainers = with lib.maintainers; [paepcke];
  };
})

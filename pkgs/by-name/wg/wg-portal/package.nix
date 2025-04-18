{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "wg-portal";
  version = "1.0.19";

  src = fetchFromGitHub {
    owner = "h44z";
    repo = "${finalAttrs.pname}";
    tag = "v${finalAttrs.version}";
    hash = "";
  };

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  vendorHash = "";

  passthru.updateScript = nix-update-script { };

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.pname}";
  versionCheckProgramArg = "--version";

  meta = {
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.pname}/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.pname};
    description = "";
    license = lib.licenses.mit;
    mainProgram = "${finalAttrs.pname}";
    maintainers = with lib.maintainers; [ paepcke ];
  };
})

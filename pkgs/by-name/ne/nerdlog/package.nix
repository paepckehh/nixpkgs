{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  writableTmpDirAsHomeHook,
  versionCheckHook,
  tmux,
  gawk,
  which,
}:
buildGoModule (finalAttrs: {
  pname = "nerdlog";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "dimonomid";
    repo = "${finalAttrs.pname}";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XlzWNeyd+Ar4ArFcN1wkQ0aod6ckAiIb12odK7cf4+s=";
  };

  env.CGO_ENABLED = 0;
  subPackages = [ "cmd/nerdlog" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/dimonomid/nerdlog/version.version=${finalAttrs.version}"
    "-X github.com/dimonomid/nerdlog/version.commit=${finalAttrs.src.rev}"
    "-X github.com/dimonomid/nerdlog/version.date=1970-01-01T00:00:00Z"
    "-X github.com/dimonomid/nerdlog/version.builtBy=nix@nixpkgs"
  ];

  vendorHash = "sha256-hvv0dsE1yz85VLaBOE7RWbux8L8kVTihcA1HyyHRYAM=";

  passthru.updateScript = nix-update-script { };

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  nativeCheckInputs = [
    tmux
    gawk
    which
  ];
  preCheck = ''
    export NERDLOG_E2E_TEST_NERDLOG_BINARY="$NIX_BUILD_TOP/go/bin/nerdlog"
  '';
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "--version";

  meta = {
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.owner}/releases/tag/v${finalAttrs.version}";
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.owner}";
    description = "Fast, remote-first, multi-host TUI log viewer with timeline histogram and no central server";
    license = lib.licenses.bsd2;
    mainProgram = "${finalAttrs.pname}";
    maintainers = with lib.maintainers; [ paepcke ];
  };
})

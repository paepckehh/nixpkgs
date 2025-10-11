{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule rec {
  pname = "upsnap";
  version = "5.2.2";

  src = fetchFromGitHub {
    owner = "seriousm4x";
    repo = "upsnap";
    name = "upsnap";
    tag = "${version}";
    hash = "sha256-07zdilpcb8ivnfqiqvrx67kpm1srrz4c945p6wbbm9frxy1wkz7a";
  };

  vendorHash = null;
  sourceRoot = "${src.name}/backend";
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/seriousm4x/UpSnap/releases/tag/${version}";
    homepage = "https://github.com/seriousm4x/UpSnap";
    description = "A simple wake on lan web app written with SvelteKit, Go and PocketBase.";
    license = lib.licenses.mit;
    mainProgram = "upsnap";
    maintainers = with lib.maintainers; [ paepcke ];
  };
}

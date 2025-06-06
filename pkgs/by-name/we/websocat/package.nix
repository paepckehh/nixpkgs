{
  lib,
  stdenv,
  bash,
  fetchFromGitHub,
  libiconv,
  makeWrapper,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage rec {
  pname = "websocat";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "vi";
    repo = "websocat";
    tag = "v${version}";
    hash = "sha256-v5+9cbKe3c12/SrW7mgN6tvQIiAuweqvMIl46Ce9f2A=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-KqtjewctX5M77aCIOpKpqlFEMs9QAzFP/v6KrZwiHb4=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libiconv
    ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  buildFeatures = [ "ssl" ];

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;

  # The wrapping is required so that the "sh-c" option of websocat works even
  # if sh is not in the PATH (as can happen, for instance, when websocat is
  # started as a systemd service).
  postInstall = ''
    wrapProgram $out/bin/websocat \
      --prefix PATH : ${lib.makeBinPath [ bash ]}
  '';

  doInstallCheck = true;

  meta = with lib; {
    description = "Command-line client for WebSockets (like netcat/socat)";
    homepage = "https://github.com/vi/websocat";
    changelog = "https://github.com/vi/websocat/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [
      thoughtpolice
      Br1ght0ne
    ];
    mainProgram = "websocat";
  };
}

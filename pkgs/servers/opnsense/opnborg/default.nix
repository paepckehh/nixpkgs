{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "opnborg";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "paepckehh";
    repo = "opnborg";
    rev = "v${version}";
    hash = "sha256-R8yl7dI+VNeY1OVoBo+CN88+2eSePjlzet/Zowj0cQs=";
  };

  vendorHash = lib.fakeSha256;

  ldflags = [
    "-s" "-w" 
  ];

  meta = with lib; {
    changelog = "https://github.com/paepckehh/opnborg/releases/tag/v${version}";
    homepage = "https://paepcke.de/opnborg";
    description = "Sefhosted OPNSense Appliance Backup & Configuration Management Portal";
    license = licenses.bsd3;
    mainProgram = "opnborg";
    maintainers = with maintainers; [ paepcke ];
  };
}

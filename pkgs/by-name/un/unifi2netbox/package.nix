{
  lib,
  python3,
  python3Packages,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "unifi2netbox";
  version = "0.0.0";
  # pyproject = false;

  src = fetchFromGitHub {
    owner = "mrzepa";
    repo = "unifi2netbox";
    rev = "d1150a5";
    hash = "sha256-5PkNHHztoxWeLx4rtEOdJJuuR8QrWp2lrEF4TSzkjko=";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      cp main.py $out/main.py
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  build-system = [python3Packages.setuptools];

  dependencies = with python3.pkgs; [
    pynetbox
    requests
    pyotp
    pyyaml
    python-dotenv
    python-slugify
    urllib3
  ];

  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup

    with open('requirements.txt') as f:
       install_requires = f.read().splitlines()

    setup(
       name='unifi2netbox',
       version='0.0.0',
       install_requires=install_requires,
       scripts=[ 'main.py'],
    )
    EOF
  '';

  # postInstall = ''install -Dm755 main.py "$out/bin/${pname}"'';

  meta = with lib; {
    homepage = "https://github.com/mrzepa/unifi2netbox";
    changelog = "https://github.com/mrzepa/unifi2netbox/commits/main/";
    description = "Scrape Unifi for devices and adds them to Netbox";
    maintainers = with maintainers; [paepcke];
    mainProgram = "${pname}";
  };
}

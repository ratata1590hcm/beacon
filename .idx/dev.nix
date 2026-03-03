{ pkgs, ... }: {
  channel = "stable-24.05";
  services.docker.enable = true;
  packages = [
    pkgs.trivy
    pkgs.ncdu
    pkgs.nano
    pkgs.htop
    pkgs.nmap
    pkgs.docker
    pkgs.docker-buildx
    pkgs.docker-compose
    pkgs.gh
    pkgs.nettools
  ];
  env = { };
  idx = {
    extensions = [
      "ms-azuretools.vscode-containers"
      "njzy.stats-bar"
      "docker.docker"
    ];
    workspace = {
      onCreate = {
        default.openFiles = [ "docker-compose.yaml" ];
      };
      onStart = {
        docker-deep-clean = ''
          ${pkgs.docker}/bin/docker system prune --all --force --volumes || true
        '';
      };
    };
  };
}
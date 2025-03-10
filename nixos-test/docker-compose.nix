# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, config, ... }:

{
  options.custom.prefix.myproject = {
    enable = lib.mkEnableOption "Enable myproject";
  };

  config = lib.mkMerge [
    (lib.mkIf config.custom.prefix.myproject.enable {

  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."myproject-entrypoint" = {
    image = "docker.io/library/nginx:stable-alpine-slim";
    log-driver = "journald";
    extraOptions = [
      "--entrypoint=[\"echo\", \"abc\"]"
      "--network-alias=entrypoint"
      "--network=myproject_default"
    ];
  };
  systemd.services."docker-myproject-entrypoint" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-myproject_default.service"
    ];
    requires = [
      "docker-network-myproject_default.service"
    ];
    partOf = [
      "docker-compose-myproject-root.target"
    ];
    upheldBy = [
      "docker-network-myproject_default.service"
    ];
    wantedBy = [
      "docker-compose-myproject-root.target"
    ];
  };
  virtualisation.oci-containers.containers."myproject-no-restart" = {
    image = "docker.io/library/nginx:stable-alpine-slim";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=no-restart"
      "--network=myproject_default"
    ];
  };
  systemd.services."docker-myproject-no-restart" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "docker-network-myproject_default.service"
    ];
    requires = [
      "docker-network-myproject_default.service"
    ];
    partOf = [
      "docker-compose-myproject-root.target"
    ];
    upheldBy = [
      "docker-network-myproject_default.service"
    ];
    wantedBy = [
      "docker-compose-myproject-root.target"
    ];
  };
  virtualisation.oci-containers.containers."myproject-service-a" = {
    image = "docker.io/library/nginx:stable-alpine-slim";
    environment = {
      "TZ" = "America/New_York";
      "test.key" = "ABC";
    };
    environmentFiles = [
      "/tmp/test.env"
    ];
    volumes = [
      "/var/volumes/service-a:/config:rw"
      "storage:/storage:rw"
    ];
    labels = {
      "compose2nix.systemd.service.Restart" = "no";
      "compose2nix.systemd.service.RuntimeMaxSec" = "360";
      "compose2nix.systemd.unit.Description" = "This is the service-a container!";
      "escape-me" = "\"hello\"";
    };
    log-driver = "journald";
    extraOptions = [
      "--cpus=0.5"
      "--network-alias=service-a"
      "--network=myproject_default"
    ];
  };
  systemd.services."docker-myproject-service-a" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
      RuntimeMaxSec = lib.mkOverride 90 360;
    };
    unitConfig = {
      Description = lib.mkOverride 90 "This is the service-a container!";
    };
    after = [
      "docker-network-myproject_default.service"
      "docker-volume-storage.service"
    ];
    requires = [
      "docker-network-myproject_default.service"
      "docker-volume-storage.service"
    ];
    partOf = [
      "docker-compose-myproject-root.target"
    ];
    upheldBy = [
      "docker-network-myproject_default.service"
      "docker-volume-storage.service"
    ];
    wantedBy = [
      "docker-compose-myproject-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/var/volumes/service-a"
    ];
  };
  virtualisation.oci-containers.containers."service-b" = {
    image = "docker.io/library/nginx:stable-alpine-slim";
    environment = {
      "TZ" = "America/New_York";
    };
    volumes = [
      "/var/volumes/service-b:/config:rw"
      "myproject_books:/books:rw"
      "storage:/storage:rw"
    ];
    labels = {
      "compose2nix.systemd.service.RuntimeMaxSec" = "360";
      "compose2nix.systemd.unit.AllowIsolate" = "no";
    };
    dependsOn = [
      "myproject-service-a"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=echo abc && true"
      "--ip=192.168.8.20"
      "--network-alias=service-b"
      "--network=myproject_something"
    ];
  };
  systemd.services."docker-service-b" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RuntimeMaxSec = lib.mkOverride 90 360;
    };
    startLimitBurst = 3;
    unitConfig = {
      AllowIsolate = lib.mkOverride 90 "no";
      StartLimitIntervalSec = lib.mkOverride 90 "infinity";
    };
    after = [
      "docker-network-myproject_something.service"
      "docker-volume-myproject_books.service"
      "docker-volume-storage.service"
    ];
    requires = [
      "docker-network-myproject_something.service"
      "docker-volume-myproject_books.service"
      "docker-volume-storage.service"
    ];
    partOf = [
      "docker-compose-myproject-root.target"
    ];
    upheldBy = [
      "docker-myproject-service-a.service"
      "docker-network-myproject_something.service"
      "docker-volume-myproject_books.service"
      "docker-volume-storage.service"
    ];
    wantedBy = [
      "docker-compose-myproject-root.target"
    ];
    unitConfig.RequiresMountsFor = [
      "/var/volumes/service-b"
    ];
  };

  # Networks
  systemd.services."docker-network-myproject_another" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f myproject_another";
    };
    script = ''
      docker network inspect myproject_another || docker network create myproject_another --driver=bridge --ipv6
    '';
    partOf = [ "docker-compose-myproject-root.target" ];
    wantedBy = [ "docker-compose-myproject-root.target" ];
  };
  systemd.services."docker-network-myproject_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f myproject_default";
    };
    script = ''
      docker network inspect myproject_default || docker network create myproject_default
    '';
    partOf = [ "docker-compose-myproject-root.target" ];
    wantedBy = [ "docker-compose-myproject-root.target" ];
  };
  systemd.services."docker-network-myproject_something" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f myproject_something";
    };
    script = ''
      docker network inspect myproject_something || docker network create myproject_something --subnet=192.168.8.0/24 --gateway=192.168.8.1 --label=escape-me='''hello''' --label=test-label=okay
    '';
    partOf = [ "docker-compose-myproject-root.target" ];
    wantedBy = [ "docker-compose-myproject-root.target" ];
  };

  # Volumes
  systemd.services."docker-volume-myproject_books" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    unitConfig.RequiresMountsFor = [
      "/mnt/media/Books"
    ];
    script = ''
      docker volume inspect myproject_books || docker volume create myproject_books --opt=device=/mnt/media/Books --opt=o=bind --opt=type=none
    '';
    partOf = [ "docker-compose-myproject-root.target" ];
    wantedBy = [ "docker-compose-myproject-root.target" ];
  };
  systemd.services."docker-volume-storage" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    unitConfig.RequiresMountsFor = [
      "/mnt/media"
    ];
    script = ''
      docker volume inspect storage || docker volume create storage --opt=device=/mnt/media --opt=o=bind --opt=type=none --label=escape-me='''hello'''
    '';
    partOf = [ "docker-compose-myproject-root.target" ];
    wantedBy = [ "docker-compose-myproject-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-myproject-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
    })
  ];
}

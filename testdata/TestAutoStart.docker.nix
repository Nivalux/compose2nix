{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."test-auto-start" = {
    image = "nginx:latest";
    labels = {
      "compose2nix.settings.autoStart" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=auto-start"
      "--network=test_default"
    ];
  };
  systemd.services."docker-test-auto-start" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-test_default.service"
    ];
    requires = [
      "docker-network-test_default.service"
    ];
    partOf = [
      "docker-compose-test-root.target"
    ];
    wantedBy = [
      "docker-compose-test-root.target"
    ];
  };
  virtualisation.oci-containers.containers."test-default-no-auto-start" = {
    image = "nginx:latest";
    log-driver = "journald";
    autoStart = false;
    extraOptions = [
      "--network-alias=default-no-auto-start"
      "--network=test_default"
    ];
  };
  systemd.services."docker-test-default-no-auto-start" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-test_default.service"
    ];
    requires = [
      "docker-network-test_default.service"
    ];
  };
  virtualisation.oci-containers.containers."test-no-auto-start" = {
    image = "nginx:latest";
    labels = {
      "compose2nix.settings.autoStart" = "false";
    };
    log-driver = "journald";
    autoStart = false;
    extraOptions = [
      "--network-alias=no-auto-start"
      "--network=test_default"
    ];
  };
  systemd.services."docker-test-no-auto-start" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-test_default.service"
    ];
    requires = [
      "docker-network-test_default.service"
    ];
  };

  # Networks
  systemd.services."docker-network-test_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f test_default";
    };
    script = ''
      docker network inspect test_default || docker network create test_default
    '';
    partOf = [ "docker-compose-test-root.target" ];
    wantedBy = [ "docker-compose-test-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-test-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
  };
}

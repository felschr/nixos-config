_:

{
  # Enable /etc/containers configuration (used by podman, cri-o, etc.)
  virtualisation.containers.enable = true;
  virtualisation.containers.containersConf.settings = {
    # Create unique User Namespace for the container
    containers.userns = "auto";
  };
  virtualisation.containers.storage.settings = {
    # defaults
    storage = {
      driver = "overlay";
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };

    # SUB_UID_MAX: https://man7.org/linux/man-pages/man5/login.defs.5.html
    storage.options.auto-userns-max-size = 600100000;
  };

  # Increase sub{u,g}id range
  users.users."root" = {
    subUidRanges = [{
      startUid = 60100000;
      count = 60000000;
    }];
    subGidRanges = [{
      startGid = 60100000;
      count = 60000000;
    }];
  };
}

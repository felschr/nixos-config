_:

{
  # Enable /etc/containers configuration (used by podman, cri-o, etc.)
  virtualisation.containers.enable = true;
  virtualisation.containers.containersConf.settings = {
    # Create unique User Namespace for the container
    containers.userns = "auto";
  };
}

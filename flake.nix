{
  description = "A collection of project templates";

  outputs = { self }: {
    templates = {
      nur = {
        path = ./nur;
        description = "Use packages available on NUR";
      };
      local = {
        path = ./local;
        description = "Use local package default.nix";
      };
      python = {
        path = ./python;
        description = "Create python 3.12 environment with libraries";
      };
      shell = {
        path = ./shell;
        description = "Use packages available on nixpkgs";
      };
      docker = {
        path = ./docker;
        description = "Build Docker images with Nix";
      };
    };
    defaultTemplate = self.templates.shell;  
    };
}

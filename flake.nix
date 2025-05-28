{
  description = "PHP + OCI8 + Oracle Instant Client (unstable)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        oracleClient = pkgs.callPackage ./oracle-instant-client { };

        php = pkgs.php84;

        oci8Ext = php.buildPecl {
          pname = "oci8";
          version = "3.4.0";
          src = pkgs.fetchurl {
            url = "https://pecl.php.net/get/oci8-3.4.0.tgz";
            sha256 = "sha256-YPXDijyQxGHZbWHFEpx4xTq3hCJU3ANVIi5t0OqMEag=";
          };
          buildInputs = [ oracleClient pkgs.pkg-config pkgs.libaio  ];
          # Untuk runtime, tambahkan propagatedBuildInputs supaya libaio ada saat load oci8.so
          propagatedBuildInputs = [ pkgs.libaio ];

          configureFlags = [ "--with-oci8=instantclient,${oracleClient}/lib/oracle" ];
        };

        phpWithOci8 = php.withExtensions (exts: [ oci8Ext ]);

      in {
        devShells.default = pkgs.mkShell {
          packages = [ 
            phpWithOci8 
            pkgs.php84Packages.composer
            pkgs.laravel
            pkgs.nodejs_24
          ];

          shellHook = ''
            export LD_LIBRARY_PATH=${oracleClient}/lib/oracle:${pkgs.libaio}/lib
            echo "PHP with oci8 ready!"
          '';
        };
      });
}

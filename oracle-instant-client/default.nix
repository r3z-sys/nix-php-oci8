{ stdenv, unzip, lib }:

# ini versi 11.2.0.4.0
stdenv.mkDerivation rec {
  pname = "oracle-instant-client";
  version = "11.2.0.4.0";

  srcs = [
    ./basic.zip
    ./sdk.zip
  ];

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    for f in $srcs; do
      unzip $f
    done
  '';

  installPhase = ''
    mkdir -p $out/lib/oracle
    cp -r * $out/lib/oracle

    # Biar libclntsh.so ada langsung di lib/oracle
    ln -s $out/lib/oracle/instantclient_11_2/* $out/lib/oracle/

    # Buat symlink libclntsh.so yang diperlukan
    ln -s $out/lib/oracle/libclntsh.so.11.1 $out/lib/oracle/libclntsh.so
  '';

  meta = with lib; {
    description = "Oracle Instant Client ${version}";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
  };
}

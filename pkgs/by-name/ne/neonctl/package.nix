{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  nodejs,
  makeWrapper,
  cacert,
}:

let
  # Create a fixed-output derivation for the dependencies
  bunDeps = stdenv.mkDerivation {
    pname = "neonctl-bun-deps";
    version = "2.15.0";

    src = fetchFromGitHub {
      owner = "neondatabase";
      repo = "neonctl";
      rev = "v2.15.0";
      hash = "sha256-jGxi3DyFIrwPK5+yUvN3WRR2/3crm6ids5y6HRToVxM=";
    };

    nativeBuildInputs = [ bun cacert ];

    buildPhase = ''
      export BUN_CACHE_DIR=$TMPDIR/bun-cache
      export HOME=$TMPDIR
      bun install --no-save --frozen-lockfile
    '';

    installPhase = ''
      cp -r node_modules $out
    '';

    # Disable script patching to avoid store path references
    dontPatchShebangs = true;
    dontPatchELF = true;

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-lssCZbVILRE3LGi8VxZlRN8cRukPfBT7/gDskEhJga8=";
  };
in
stdenv.mkDerivation rec {
  pname = "neonctl";
  version = "2.15.0";

  src = fetchFromGitHub {
    owner = "neondatabase";
    repo = "neonctl";
    rev = "v${version}";
    hash = "sha256-jGxi3DyFIrwPK5+yUvN3WRR2/3crm6ids5y6HRToVxM=";
  };

  nativeBuildInputs = [
    bun
    nodejs
    makeWrapper
  ];

  # Copy pre-built dependencies
  preBuild = ''
    export BUN_CACHE_DIR=$TMPDIR/bun-cache
    export HOME=$TMPDIR
    cp -r ${bunDeps} node_modules
    chmod -R +w node_modules
  '';

  buildPhase = ''
    runHook preBuild

    # Generate parameters using Bun
    bun generateOptionsFromSpec.ts

    # Clean and build
    rm -rf dist
    bun build src/index.ts --outdir dist --target node

    # Copy additional files
    cp src/*.html package*.json README.md ./dist/ || true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/neonctl

    # Copy built files
    cp -r dist/* $out/lib/neonctl/

    # Create wrapper script that uses node to run the built JS
    makeWrapper ${nodejs}/bin/node $out/bin/neonctl \
      --add-flags "$out/lib/neonctl/index.js"

    runHook postInstall
  '';

  meta = {
    description = "Command-line interface that lets you manage Neon Serverless Postgres directly from the terminal";
    longDescription = ''
      The Neon CLI is a command-line interface that lets you manage Neon Serverless Postgres
      directly from the terminal. Supports authentication via browser or API key, manages
      projects, branches, databases, roles, and provides CLI autocompletion.
    '';
    homepage = "https://github.com/neondatabase/neonctl";
    changelog = "https://github.com/neondatabase/neonctl/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ connerohnesorge ];
    platforms = lib.platforms.all;
    mainProgram = "neonctl";
  };
}
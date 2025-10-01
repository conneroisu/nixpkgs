{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_9,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mcp-remote";
  version = "0.1.29";

  src = fetchFromGitHub {
    owner = "geelen";
    repo = "mcp-remote";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RnyxKVc6+TZ6JhNMoV44hWp9s6+TuN2eIGTrYwTtMxA=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 1;
    hash = "sha256-t+epNN+P5daANetd6j32of7PAEJd0zenGvloeuU5i8Q=";
  };

  nativeBuildInputs = [
    pnpm_9.configHook
  ];

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/mcp-remote}
    cp -r {dist,node_modules,package.json} $out/lib/mcp-remote

    # Create symlinks to the executables
    ln -s $out/lib/mcp-remote/dist/proxy.js $out/bin/mcp-remote
    ln -s $out/lib/mcp-remote/dist/client.js $out/bin/mcp-remote-client

    runHook postInstall
  '';

  meta = {
    description = "Connect an MCP Client that only supports local (stdio) servers to a Remote MCP Server, with auth support";
    homepage = "https://github.com/geelen/mcp-remote";
    license = lib.licenses.mit;
    mainProgram = "mcp-remote";
    maintainers = [ ];
    platforms = nodejs.meta.platforms;
  };
})

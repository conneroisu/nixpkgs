{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
  makeWrapper,
  ...
}:
buildNpmPackage (finalAttrs: {
  pname = "shopify-mcp-server";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Shopify";
    repo = "dev-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rwA+qkOXvB3stRAuOHVAwx/BUNz5QawP76Fo2EuTDY8=";
  };

  npmDepsHash = "sha256-k1cU7w9ZWqeJnIcACo49aZRyNMMzGcigLy2QyFxW/jU=";

  nativeBuildInputs = [
    makeWrapper
    nodejs
  ];

  # Use the build script from package.json
  npmBuildScript = "build";

  # Post-installation setup
  postInstall = ''
    # Make the main file executable and create wrapper
    if [ -f $out/lib/node_modules/@shopify/dev-mcp/dist/index.js ]; then
      chmod +x $out/lib/node_modules/@shopify/dev-mcp/dist/index.js
      makeWrapper $out/lib/node_modules/@shopify/dev-mcp/dist/index.js $out/bin/shopify-dev-mcp \
        --prefix PATH : ${lib.makeBinPath [nodejs]}
    else
      echo "Warning: dist/index.js not found, checking for other entry points..."
      find $out/lib/node_modules/@shopify/dev-mcp -name "*.js" -type f | head -5
    fi
  '';

  meta = {
    description = "Shopify Dev Model Context Protocol (MCP) Server";
    longDescription = ''
      The Shopify Dev MCP Server is a TypeScript implementation of the Model Context
      Protocol (MCP) server that provides seamless integration with Shopify Dev APIs,
      enabling advanced automation and interaction capabilities for developers
      and AI tools.

      This server allows LLMs to interact with Shopify Admin GraphQL API, Functions,
      and optional Polaris Web Components through structured API interactions.
    '';
    homepage = "https://github.com/Shopify/dev-mcp";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [connerohnesorge];
    mainProgram = "shopify-dev-mcp";
  };
})

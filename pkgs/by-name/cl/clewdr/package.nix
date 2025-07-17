{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  darwin,
  cmake,
  go,
  perl,
  git,
  testers,
  clewdr,
}:

rustPlatform.buildRustPackage rec {
  pname = "clewdr";
  version = "0.10.9";

  src = fetchFromGitHub {
    owner = "Xerxes-2";
    repo = "clewdr";
    rev = "v${version}";
    hash = "sha256-P+HzZ3+9VT0aPZJOP6U9KLyDLVqAE1xjXNjnC9fuEPE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-9V4Ud5Vyvq5TnjokxfvhIctp4hKwbt7plpgMzqTWJM8=";

  # Enable Rust edition 2024 (remove if updating to rust 1.85)
  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail "[package]" '''$'cargo-features = ["edition2024"]
[package]'
  '';

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    cmake
    go
    perl
    git
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  # Some tests require network access
  doCheck = false;

  preBuild = ''
    # Create empty static directory required by include_dir! macro in router.rs
    # This would normally contain frontend assets but we build with no_fs feature
    mkdir -p static

    # Add missing Future trait imports required for async function signatures
    sed -i '1iuse std::future::Future;' src/claude_code_state/exchange.rs
    sed -i '1iuse std::future::Future;' src/error.rs
  '';

  # Enable unstable features (remove if updating to rust 1.85)
  env.RUSTC_BOOTSTRAP = 1;

  # Use no_fs feature to disable filesystem operations
  buildFeatures = [ "no_fs" ];

  passthru = {
    tests = {
      version = testers.testVersion { package = clewdr; };
    };
  };

  meta = {
    description = "High-performance LLM reverse proxy for Claude and Google Gemini";
    longDescription = ''
      ClewdR is a production-grade, high-performance proxy server engineered specifically
      for Claude (Claude.ai, Claude Code) and Google Gemini (AI Studio, Vertex AI).
      Built with Rust for maximum performance and minimal resource usage, it provides
      enterprise-level reliability with consumer-friendly simplicity.

      Features include:
      - 10x performance compared to script-language implementations
      - Single-digit MB memory usage in production
      - Full-featured web interface with real-time monitoring
      - Multi-language support (English/Chinese)
      - OpenAI-compatible API endpoints for drop-in replacement
      - Support for streaming responses and image attachments
    '';
    homepage = "https://github.com/Xerxes-2/clewdr";
    changelog = "https://github.com/Xerxes-2/clewdr/blob/v${version}/RELEASE_NOTES.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "clewdr";
    platforms = lib.platforms.unix;
  };
}

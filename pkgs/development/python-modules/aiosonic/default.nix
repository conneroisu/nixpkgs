{
  nodejs,
  lib,
  buildPythonPackage,
  pythonOlder,
  fetchFromGitHub,
  poetry-core,
  # install_requires
  charset-normalizer,
  h2,
  onecache,
  # test dependencies
  httpx,
  pytest-aiohttp,
  pytest-cov-stub,
  pytest-mock,
  uvicorn,
  requests,
  aiohttp,
  pytestCheckHook,
  stdenv,
}:

buildPythonPackage rec {
  pname = "aiosonic";
  version = "0.22.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  __darwinAllowLocalNetworking = true;

  src = fetchFromGitHub {
    owner = "sonic182";
    repo = "aiosonic";
    tag = version;
    hash = "sha256-wBYGiSTSRhi11uqTyGgF1YpnBVoDraCr2GKC8VkQEWc=";
  };

  postPatch = ''
    substituteInPlace pytest.ini --replace-fail \
      "addopts = --black " \
      "addopts = "
  '';

  build-system = [ poetry-core ];

  dependencies = [
    charset-normalizer
    onecache
    h2
  ];

  nativeCheckInputs = [
    aiohttp
    httpx
    pytest-aiohttp
    pytest-cov-stub
    pytest-mock
    uvicorn
    requests
    pytestCheckHook
  ];

  pythonImportsCheck = [ "aiosonic" ];

  disabledTests =
    lib.optionals stdenv.hostPlatform.isLinux [
      # need network
      "test_simple_get"
      "test_get_python"
      "test_post_http2"
      "test_get_http2"
      "test_method_lower"
      "test_keep_alive_smart_pool"
      "test_keep_alive_cyclic_pool"
      "test_get_with_params"
      "test_get_with_params_in_url"
      "test_get_with_params_tuple"
      "test_post_form_urlencoded"
      "test_post_tuple_form_urlencoded"
      "test_post_json"
      "test_put_patch"
      "test_delete"
      "test_delete_2"
      "test_get_keepalive"
      "test_post_multipart_to_django"
      "test_connect_timeout"
      "test_read_timeout"
      "test_timeouts_overriden"
      "test_pool_acquire_timeout"
      "test_simple_get_ssl"
      "test_simple_get_ssl_ctx"
      "test_simple_get_ssl_no_valid"
      "test_get_chunked_response"
      "test_get_chunked_response_and_not_read_it"
      "test_read_chunks_by_text_method"
      "test_get_body_gzip"
      "test_get_body_deflate"
      "test_post_chunked"
      "test_close_connection"
      "test_close_old_keeped_conn"
      "test_get_redirect"
      "test_max_redirects"
      "test_get_image"
      "test_get_image_chunked"
      "test_get_with_cookies"
      "test_proxy_request"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # "FAILED tests/test_proxy.py::test_proxy_request - Exception: port 8865 never got active"
      "test_proxy_request"
    ];

  meta = {
    changelog = "https://github.com/sonic182/aiosonic/blob/${version}/CHANGELOG.md";
    description = "Very fast Python asyncio http client";
    license = lib.licenses.mit;
    homepage = "https://github.com/sonic182/aiosonic";
    maintainers = with lib.maintainers; [ geraldog ];
  };
}

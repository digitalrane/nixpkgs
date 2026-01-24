{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  cmake,
  nlohmann_json,
  pkg-config,
  gtk3,
  wayland-scanner,
  wayfire,
  wf-config,
  wlroots,
  libxkbcommon,
  libinput,
  vulkan-headers,
  xcbutilwm,
}:

stdenv.mkDerivation rec {
  pname = "wf-external-decoration";
  version = "6507717313be4975e8260ecedef5eac1bf752b7c";

  src = fetchFromGitHub {
    owner = "digitalrane";
    repo = "wf-external-decoration";
    rev = "${version}";
    hash = "sha256-GmBJIwQBVnlLJsTKIa/h2h5+chBOUsZDgnlSUM8lN+g=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    cmake
  ];

  buildInputs = [
    vulkan-headers
    nlohmann_json
    wayfire
    gtk3
    wlroots
    libxkbcommon
    wf-config
    libinput
    xcbutilwm
  ];

  nativeCheckInputs = [
    cmake
  ];

  env = {
    PKG_CONFIG_WAYFIRE_METADATADIR = "${placeholder "out"}/share/wayfire/metadata";
    PKG_CONFIG_WAYFIRE_PLUGINDIR = "${placeholder "out"}/lib/wayfire";
    PKG_CONFIG_WAYFIRE_ICONDIR = "${placeholder "out"}/share/wayfire/icons";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace "dependency('wlroots')" "dependency('wlroots-0.19')"
    substituteInPlace wf-metacity-decorator/meson.build \
      --replace "/usr/bin" "${placeholder "out"}/bin"
  '';

  meta = {
    description = "A wayfire decoration plugin that uses a external executable";
    inherit (src.meta) homepage;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ digitalrane ];
    platforms = lib.platforms.linux;
    mainProgram = "wf-external-decoration";
  };
}

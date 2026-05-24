{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  bash,
  iproute2,
  fping,
  iputils,
  util-linux,
  gzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cake-autorate";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "lynxthecat";
    repo = "cake-autorate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2WnMmilrVgVwjHK5ZkoXrzVlofuvvwQbSROfvd4RbEk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 cake-autorate.sh "$out/lib/cake-autorate/cake-autorate.sh"
    install -Dm644 lib.sh "$out/lib/cake-autorate/lib.sh"
    install -Dm644 defaults.sh "$out/lib/cake-autorate/defaults.sh"

    makeWrapper "$out/lib/cake-autorate/cake-autorate.sh" "$out/bin/cake-autorate" \
      --set CAKE_AUTORATE_SCRIPT_PREFIX "$out/lib/cake-autorate" \
      --prefix PATH : "${
        lib.makeBinPath [
          bash
          iproute2
          fping
          iputils
          util-linux
          gzip
        ]
      }"

    runHook postInstall
  '';

  meta = {
    description = "Automatically adjusts CAKE bandwidth for variable-rate connections";
    homepage = "https://github.com/lynxthecat/cake-autorate";
    changelog = "https://github.com/lynxthecat/cake-autorate/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ rane ];
    platforms = lib.platforms.linux;
    mainProgram = "cake-autorate";
  };
})

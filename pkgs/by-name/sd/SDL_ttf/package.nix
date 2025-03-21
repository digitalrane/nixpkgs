{
  lib,
  SDL,
  fetchpatch,
  fetchurl,
  freetype,
  stdenv,
  # Boolean flags
  enableSdltest ? (!stdenv.hostPlatform.isDarwin),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SDL_ttf";
  version = "2.0.11";

  src = fetchurl {
    url = "https://www.libsdl.org/projects/SDL_ttf/release/SDL_ttf-${finalAttrs.version}.tar.gz";
    hash = "sha256-ckzYlez02jGaPvFkiStyB4vZJjKl2BIREmHN4kjrzbc=";
  };

  patches = [
    # Bug #830: TTF_RenderGlyph_Shaded is broken
    (fetchpatch {
      url = "https://bugzilla-attachments.libsdl.org/attachments/830/renderglyph_shaded.patch.txt";
      hash = "sha256-TZzlZe7gCRA8wZDHQZsqESAOGbLpJzIoB0HD8L6z3zE=";
    })
  ];

  patchFlags = [ "-p0" ];

  buildInputs = [
    SDL
    freetype
  ];

  # pass in correct *-config for cross builds
  env.SDL_CONFIG = lib.getExe' (lib.getDev SDL) "sdl-config";
  env.FREETYPE_CONFIG = lib.getExe' freetype.dev "freetype-config";

  configureFlags = [
    (lib.enableFeature enableSdltest "sdltest")
  ];

  strictDeps = true;

  meta = {
    homepage = "https://github.com/libsdl-org/SDL_ttf";
    description = "SDL TrueType library";
    license = lib.licenses.zlib;
    maintainers = lib.teams.sdl.members ++ (with lib.maintainers; [ ]);
    inherit (SDL.meta) platforms;
    knownVulnerabilities = [
      "CVE-2022-27470"
    ];
  };
})

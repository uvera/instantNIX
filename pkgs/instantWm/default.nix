{ lib
, stdenv
, fetchFromGitHub
, gnumake
, xlibs
, pavucontrol
, rofi
, rxvt_unicode
, st
, cantarell-fonts
, joypixels
, instantAssist
, instantUtils
, instantDotfiles
, wmconfig ? null
, extraPatches ? []
, defaultTerminal ? st
}:
stdenv.mkDerivation {

  pname = "instantWm";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "instantOS";
    repo = "instantWM";
    rev = "64cc5fbcc6fb8d72a64528c8d2abaa7f419256e9";
    sha256 = "1a9z8s0a55aby1ixgqwa3m7zxyfb7730y7ygdf5ppnc5jsvkq5r7";
    name = "instantOS_instantWm";
  };

  patches = [ ] ++ extraPatches;

  postPatch =  
  ( if builtins.isPath wmconfig then "cp ${wmconfig} config.def.h\n" else "" ) + 
  ''
    substituteInPlace config.mk \
      --replace "PREFIX = /usr/local" "PREFIX = $out"
    substituteInPlace config.def.h \
      --replace "\"pavucontrol\"" "\"${pavucontrol}/bin/pavucontrol\"" \
      --replace "\"rofi\"" "\"${rofi}/bin/rofi\"" \
      --replace "\"urxvt\"" "\"${rxvt_unicode}/bin/urxvt\"" \
      --replace "\"st\"" "\"${defaultTerminal}/bin/${builtins.head (builtins.match "(.*)-.*" defaultTerminal.name)}\"" \
      --replace /usr/share/instantassist/ "${instantAssist}/share/instantassist/" \
      --replace /usr/share/instantdotfiles/ "${instantDotfiles}/share/instantdotfiles/"
  '';

  nativeBuildInputs = [ gnumake ];
  buildInputs = with xlibs; map lib.getDev [ libX11 libXft libXinerama ];
  propagatedBuildInputs = [
    cantarell-fonts
    joypixels
    pavucontrol
    rofi
    rxvt_unicode
    defaultTerminal
  ] ++
  [
    instantAssist
    instantUtils
  ];

  installPhase = ''
    install -Dm 555 instantwm $out/bin/instantwm
    install -Dm 555 startinstantos $out/bin/startinstantos
    mkdir $out/debug/ && cp config.def.h $out/debug/  # not needed, makes debugging a bit easier
  '';

  meta = with lib; {
    description = "Window manager of instantOS.";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantWM";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

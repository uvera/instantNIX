{ lib
, stdenv
, fetchFromGitHub
, sqlite
}:
stdenv.mkDerivation {

  pname = "instantShell";
  version = "unstable";

  srcs = [ 
    (fetchFromGitHub {
      owner = "instantOS";
      repo = "instantshell";
      rev = "482d900c4e18a1dab2f8893ff10687fb3c8d016a";
      sha256 = "sha256-9sDDwp0SxLbTtC53hrR5uKoHiBmFjTDTLHdMaXXft6Y=";
      name = "instantOS_instantShell";
    })
    (fetchFromGitHub {
      owner = "ohmyzsh";
      repo = "ohmyzsh";
      rev = "c52e646bb7b109e15f6dc4047b29ca8c8e029433";
      sha256 = "sha256-yYvXD9z9ADeklGE6Enw3gsW8J7KM6lA98ksZlSxU13k=";
      name = "ohmyzsh";
    })
  ];

  sourceRoot = ".";

  postPatch = ''
    ls -lh
    substituteInPlace instantOS_instantShell/install.sh \
      --replace "/usr/share/" "$out/share/"
    cat instantOS_instantShell/zshrc >> ohmyzsh/templates/zshrc.zsh-template
    rm instantOS_instantShell/zshrc
  '';

  installPhase = ''
    install -Dm 644 instantOS_instantShell/instantos.plugin.zsh $out/share/instantshell/custom/plugins/instantos/instantos.plugin.zsh
    install -Dm 644 instantOS_instantShell/instantos.zsh-theme $out/share/instantshell/custom/themes/instantos.zsh-theme
    install -Dm 555 instantOS_instantShell/install.sh $out/bin/instantshell
    cp -r ohmyzsh/* $out/share/instantshell
  '';

  meta = with lib; {
    description = "instantOS Shell";
    license = licenses.mit;
    homepage = "https://github.com/instantOS/instantshell";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

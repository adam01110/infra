{
  perSystem = {pkgs, ...}: let
    inherit
      (pkgs)
      # keep-sorted start
      fetchurl
      runCommand
      # keep-sorted end
      ;
  in {
    # Solar icon pack with classes renamed to Discord's Nov 2026 hash format.
    packages.discord-solar-icons =
      runCommand "solar.css" {
        src = fetchurl {
          url = "https://raw.githubusercontent.com/mudrhiod/discord-iconpacks/6e32a7678531d1be32bb59aa1b6d282f6fb73e8a/vencord/solar/solar.css";
          hash = "sha256-X159xiOieTF8e1GYsRKuEl6vR19cZYaMCiw0vPfEmFk=";
        };
      } ''
        substitute $src $out \
          --replace-fail "buttonWrapper__24af7" "buttonWrapper_hfM7yP" \
          --replace-fail "button__67645" "button_Y-8oZW" \
          --replace-fail "button__74017" "button_2x8-Qn" \
          --replace-fail "buttons__74017" "buttons_2x8-Qn" \
          --replace-fail "container__37e49" "container_g6VwXp" \
          --replace-fail "icon_c1e9c4" "icon_M3qk4j" \
          --replace-fail "icon_caf372" "icon_xyJHva" \
          --replace-fail "spriteContainer__04eed" "spriteContainer_SjG8Ug" \
          --replace-fail "sprite__04eed" "sprite_SjG8Ug" \
          --replace-fail "stickerButton__74017" "stickerButton_2x8-Qn" \
          --replace-fail "winButton_c38106" "winButton_3zSH5d"
      '';
  };
}

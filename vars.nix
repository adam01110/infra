rec {
  # Identity shared across modules.
  # keep-sorted start
  fullName = "Adam0";
  username = "adam0";
  # keep-sorted end

  # Git and identity.
  # keep-sorted start
  gitPublicSshkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDk3Fc80bWSFt41iDx1pzhFHP8EzDwJwPiyrhVV01i+9 Authentication key alumail@protonmail.com";
  gitSigningKey = "0FFE5DE6328D5EC9";
  gitUsername = "${username}1110";
  # keep-sorted end

  # Regional defaults for locale-sensitive modules.
  # keep-sorted start
  countryCode = "NL";
  defaultLocale = "en_US.UTF-8";
  noctaliaFirstDayOfWeek = 1;
  regionalLocale = "nl_${countryCode}.UTF-8";
  # keep-sorted end
}

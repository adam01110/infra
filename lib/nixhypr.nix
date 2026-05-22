_: {
  mkNixhyprBind = description: keys: dispatcher:
    {
      inherit description keys;
    }
    // dispatcher;

  mkNixhyprBindGroup = category: binds: {
    inherit
      # keep-sorted start
      binds
      category
      # keep-sorted end
      ;
  };
}

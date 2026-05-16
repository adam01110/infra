_: {
  mkYaziUrlEntries = run:
    map (url: {
      inherit url run;
    });
}

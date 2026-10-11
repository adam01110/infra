_: {
  # Map Stylix base16 colors onto a Glamour style accepted by glow -s.
  mkGlamourStyle = colors: let
    inherit
      (colors)
      # keep-sorted start
      base00
      base02
      base03
      base04
      base05
      base08
      base09
      base0A
      base0B
      base0C
      base0D
      base0E
      # keep-sorted end
      ;

    chroma = {
      # keep-sorted start block=yes newline_separated=yes
      background.background_color = base02;

      comment.color = base03;

      comment_preproc.color = base09;

      error = {
        background_color = base00;
        color = base08;
      };

      generic_deleted.color = base08;

      generic_emph.italic = true;

      generic_inserted.color = base0B;

      generic_strong.bold = true;

      generic_subheading.color = base04;

      keyword.color = base0E;

      keyword_namespace.color = base08;

      keyword_reserved.color = base0E;

      keyword_type.color = base0A;

      literal.color = base05;

      literal_date.color = base0C;

      literal_number.color = base09;

      literal_string.color = base0B;

      literal_string_escape.color = base0C;

      name.color = base05;

      name_attribute.color = base0A;

      name_builtin.color = base08;

      name_class = {
        bold = true;
        color = base0A;
        underline = true;
      };

      name_constant.color = base09;

      name_decorator.color = base0A;

      name_exception.color = base08;

      name_function.color = base0D;

      name_other.color = base05;

      name_tag.color = base0E;

      operator.color = base0C;

      punctuation.color = base05;
      # keep-sorted end
    };
  in {
    # keep-sorted start block=yes newline_separated=yes
    block_quote = {
      color = base04;
      indent = 1;
      indent_token = "│ ";
    };

    code = {
      background_color = base02;
      color = base0B;
      prefix = " ";
      suffix = " ";
    };

    code_block = {
      color = base05;
      margin = 2;
      inherit chroma;
    };

    definition_description.block_prefix = "\n🠶 ";

    document = {
      block_prefix = "\n";
      block_suffix = "\n";
      color = base05;
      margin = 2;
    };

    emph.italic = true;

    enumeration = {
      block_prefix = ". ";
      color = base0E;
    };

    h1 = {
      background_color = base0D;
      bold = true;
      color = base00;
      prefix = " ";
      suffix = " ";
    };

    h2.prefix = "## ";

    h3.prefix = "### ";

    h4.prefix = "#### ";

    h5.prefix = "##### ";

    h6 = {
      bold = false;
      color = base04;
      prefix = "###### ";
    };

    heading = {
      block_suffix = "\n";
      bold = true;
      color = base0D;
    };

    hr = {
      color = base03;
      format = "\n--------\n";
    };

    image = {
      color = base0E;
      underline = true;
    };

    image_text = {
      color = base04;
      format = "Image: {{.text}} →";
    };

    item = {
      block_prefix = "• ";
      color = base0E;
    };

    link = {
      color = base0C;
      underline = true;
    };

    link_text = {
      bold = true;
      color = base0C;
    };

    list.level_indent = 2;

    strikethrough.crossed_out = true;

    strong.bold = true;

    task = {
      ticked = "[✓] ";
      unticked = "[ ] ";
    };
    # keep-sorted end
  };
}

{
  flake.modules.homeManager.neovim.programs.nvf.settings.vim.keymaps = [
    # Buffer selection
    # keep-sorted start block=yes newline_separated=yes
    {
      key = "<leader>1";
      mode = "n";
      action = "<cmd>lua local b = vim.fn.getbufinfo({ buflisted = 1 })[1]; if b then vim.api.nvim_set_current_buf(b.bufnr) end<cr>";
      desc = "Select buffer 1";
    }

    {
      key = "<leader>2";
      mode = "n";
      action = "<cmd>lua local b = vim.fn.getbufinfo({ buflisted = 1 })[2]; if b then vim.api.nvim_set_current_buf(b.bufnr) end<cr>";
      desc = "Select buffer 2";
    }

    {
      key = "<leader>3";
      mode = "n";
      action = "<cmd>lua local b = vim.fn.getbufinfo({ buflisted = 1 })[3]; if b then vim.api.nvim_set_current_buf(b.bufnr) end<cr>";
      desc = "Select buffer 3";
    }

    {
      key = "<leader>4";
      mode = "n";
      action = "<cmd>lua local b = vim.fn.getbufinfo({ buflisted = 1 })[4]; if b then vim.api.nvim_set_current_buf(b.bufnr) end<cr>";
      desc = "Select buffer 4";
    }

    {
      key = "<leader>5";
      mode = "n";
      action = "<cmd>lua local b = vim.fn.getbufinfo({ buflisted = 1 })[5]; if b then vim.api.nvim_set_current_buf(b.bufnr) end<cr>";
      desc = "Select buffer 5";
    }

    {
      key = "<leader>6";
      mode = "n";
      action = "<cmd>lua local b = vim.fn.getbufinfo({ buflisted = 1 })[6]; if b then vim.api.nvim_set_current_buf(b.bufnr) end<cr>";
      desc = "Select buffer 6";
    }

    {
      key = "<leader>7";
      mode = "n";
      action = "<cmd>lua local b = vim.fn.getbufinfo({ buflisted = 1 })[7]; if b then vim.api.nvim_set_current_buf(b.bufnr) end<cr>";
      desc = "Select buffer 7";
    }

    {
      key = "<leader>8";
      mode = "n";
      action = "<cmd>lua local b = vim.fn.getbufinfo({ buflisted = 1 })[8]; if b then vim.api.nvim_set_current_buf(b.bufnr) end<cr>";
      desc = "Select buffer 8";
    }

    {
      key = "<leader>9";
      mode = "n";
      action = "<cmd>lua local b = vim.fn.getbufinfo({ buflisted = 1 })[9]; if b then vim.api.nvim_set_current_buf(b.bufnr) end<cr>";
      desc = "Select buffer 9";
    }
    # keep-sorted end

    # File operations
    # keep-sorted start block=yes newline_separated=yes
    {
      key = "<leader>Q";
      mode = "n";
      action = "<cmd>q!<cr>";
      desc = "Force quit window";
    }

    {
      key = "<leader>q";
      mode = "n";
      action = "<cmd>q<cr>";
      desc = "Quit window";
    }

    {
      key = "<leader>w";
      mode = "n";
      action = "<cmd>w<cr>";
      desc = "Write file";
    }

    {
      key = "<leader>x";
      mode = "n";
      action = "<cmd>x<cr>";
      desc = "Write and quit";
    }
    # keep-sorted end

    # Buffer navigation
    # keep-sorted start block=yes newline_separated=yes
    {
      key = "[";
      mode = "n";
      action = "<cmd>bprevious<cr>";
      desc = "Previous buffer";
    }

    {
      key = "]";
      mode = "n";
      action = "<cmd>bnext<cr>";
      desc = "Next buffer";
    }
    # keep-sorted end
  ];
}

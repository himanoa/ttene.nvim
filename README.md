# ttene.nvim

改行するときだけではなくノーマルモード離脱時も喋ります

## 依存関係

- mplayer, afplay or other similar program
- magicalstick(https://github.com/himanoa/magicalstick)

## インストール(lazy.nvim)

```lazy.nvim
require("lazy").setup({
  {
    "orumin/ttene.nvim",
    lazy = true,
    events = VeryLazy,
    cond = true,
    build = function()
      local is_win = vim.fn.has("win32") == 1
      local path_sep = is_win and "\\" or "/"
      local voices_dir = table.concat({vim.fn.stdpath("data"), "ttene", ""}, path_sep) -- *nix: '$HOME/.local/share/nvim/ttene/', Windows: '%LOCALAPPDATA%\nvim-data\ttene\'
      if not is_win then
        os.execute("mkdir -p " .. voices_dir)
        os.execute("magicalstick | grep てねっ[0-9] | xargs -P4 -In1 wget n1 -P " .. voices_dir)
      else
        -- NOTE: add command to retrieve voice files for Windows
      end
    end
  }
})
```

## 設定例

```lazy.nvim
require("lazy").setup({
  {
    "orumin/ttene.nvim",
    lazy = true,
    events = "InsertEnter",
    opts = {
      cmd = "afplay", -- use 'mplayer' in default
      voices_dir = table.concat({vim.env.HOME, "ttene", "voices", ""}, path_sep) -- change voice files directory to '$HOME/ttene/voices/'
    },
    cond = function(opts)
    end,
    build = function()
      local path_sep = vim.fn.has("win32") == 1 and "\\" or "/"
      local voices_dir = table.concat({vim.env.HOME, "ttene", "voices", ""}, path_sep)
      if not is_win then
        os.execute("mkdir -p " .. voices_dir)
        os.execute("magicalstick | grep てねっ[0-9] | xargs -P4 -In1 wget n1 -P " .. voices_dir)
      end
    end
  }
})
```

## Porting

- Emacs [shibafu528/ttene-mode](https://github.com/shibafu528/ttene-mode)
- Zsh [atnanasi/ttene.zsh](https://github.com/atnanasi/ttene.zsh)
- Atom [ueken0307/natorisana-voice](https://github.com/ueken0307/natorisana-voice)

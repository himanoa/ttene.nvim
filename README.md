# ttene.nvim

## 依存関係

- asyncrun.vim(https://github.com/skywind3000/asyncrun.vim)
- mplayer or afplay
- magicalstick(https://github.com/himanoa/magicalstick)

## インストール(dein)

```dein.toml
[[plugins]]
repo = "skywind3000/asyncrun.vim"

[[plugins]]
repo = "himanoa/ttene.nvim"
hook_post_update = '''
  let g:dein#plugin.build = 'magicalstick | grep てねっ[0-9] | xargs -P4 -In1 wget n1 -P voices/'
'''
```

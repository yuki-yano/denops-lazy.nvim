# denops-lazy.nvim

Plugin for lazy load of [denops.vim](https://github.com/vim-denops/denops.vim) plugin with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Usage

Execute the `load` function of denops-lazy.nvim in the `config` property of lazy.nvim.

```lua
return {
  { 'vim-denops/denops.vim', event = { 'VeryLazy' } },
  {
    'yuki-yano/fuzzy-motion.vim',
    dependencies = {
      { 'vim-denops/denops.vim' },
    },
    cmd = { 'FuzzyMotion' },
    config = function()
      require('denops-lazy').load('fuzzy-motion.vim')
    end,
  },
}
```

## Option

The second argument of load specifies options for loading.

### `wait_load`

Run `denops#plugin#wait` after loading a plugin and wait for the plugin to complete loading.

default: `true`

### `wait_server`

Wait for startup if the denops server has not completed startup.

default: `true`

### `wait_server_delay`

Time to wait for the denops to start (milliseconds)

default: `10`

### `wait_server_retry_limit`

Number of times to wait for denops to start

default: `100`

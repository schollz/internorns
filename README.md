## voyage

a cyberdeck to use norns from vim.


### Requirements

- norns

### Documentation

#### keyboard sounds

keyboard sounds are piped in through supercollider from osc messages. you can setup a key logger on your computer that will send osc messages on key press.

from your host computer (Windows-only currently) install with

```
git clone https://github.com/schollz/osckeylogger
cd osckeylogger
go install -v
```

then use with

```
osckeylogger --host "<supercollider host>"
```


#### using with vim

lines from a norns script can be quickly and easily run using vim.

to use with vim, first download `wscat` - a utility for piping commands to the maiden websocket server.

```
wget https://github.com/schollz/wscat/releases/download/binaries/wscat
chmod +x wscat
sudo mv wscat /usr/local/bin/
```

then you can edit your `.vimrc` file to include these lines which will automatically run
the current selected line when you press <kbd>ctl</kbd>+<kbd>c</kbd>:

```vim
set underline
nnoremap <C-c> <esc>:silent.w !wscat<enter>
inoremap <C-c> <esc>:silent.w !wscat<enter>i
```

now whenever you use the key combo <kbd>ctl</kbd>+<kbd>c</kbd> it will send the current line in vim into maiden!


### Install

```
;install https://github.com/schollz/voyage
```
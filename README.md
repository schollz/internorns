# internorns

a live-coding environment that interconnects norns.

this script is essentially *lua sequencer*. that is, you can write lines of code have them be executed at time intervals, similar to a tracker. by default there are 4 steps per beat which can hold any amount of code that will be run at that step.

the code you can sequence is any norns code. in addition to the standard norns features (midi, osc, crow), I've added in simple interfaces to "lite" versions of several of my own scripts. here is a list of easily controllable entities:

- midi pitches and cc lfos
- crow pitches and envelope (or crow anything)
- three stereo digital tapes a la [*oooooo*](https://llllllll.co/t/oooooo)
- built-in drums from [supertonic](https://llllllll.co/t/supertonic/)
- sample player similar to [amen](https://llllllll.co/t/amen/)
- instrument samples from [mx.samples](https://llllllll.co/t/mx-samples/)
- special tape stop / start global fx
- grid control into [plonky sequencer](https://llllllll.co/t/plonky/)
- sequencing pitches is faciliated by simply describing pitches using note/chord names (e.g. `Cm7/Eb` or `a4`). 

using this script means that you first must run the script and then open up an editor of your choice (see documentation) and then run various lines of code to add code to the lua sequencer. the process is music.


## Requirements

- norns

## Documentation

1. first you can choose an editor - maiden, visual studio code, and vim are all great options.

2. then open up `~/dust/code/internorns/decks/basic.lua` and follow the tutorial.

3. then code your own deck!


### maiden

open up a webbrowser to [norns.local/maiden/#edit/dust/code/internorns/decks/basic.lua](norns.local/maiden/#edit/dust/code/internorns/decks/basic.lua).

you can select any code and press <kbd>ctl</kbd>+<kbd>enter</kdb> to send that code to the norns.

### visual studio code

[download visual studio code](https://code.visualstudio.com/) and then install [the Norns REPL extension](https://llllllll.co/t/norns-repl-vscode-extension/41382). use software like [sftp drive](https://www.nsoftware.com/sftp/drive/) to mount your norns on your computer. then you can directly edit `~/dust/code/internorns/decks/basic.lua`. 

press <kbd>ctl</kbd>+<kbd>enter</kdb> to send the current line to the norns.

### vim

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
;install https://github.com/schollz/mx.samples
;install https://github.com/schollz/plonky
;install https://github.com/schollz/supertonic
;install https://github.com/schollz/internorns
```

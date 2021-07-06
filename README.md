# internorns

a live-coding interface that interconnects norns.

![internorns](https://user-images.githubusercontent.com/6550035/124368779-70d17380-dc19-11eb-9590-3fa4101337c9.jpg)

https://vimeo.com/570686702

this script is a cross between a [live coding environment](https://llllllll.co/t/live-coding/5032) and a [tracker](https://llllllll.co/t/trackers/38551) - its sorta a tracker you sequence with code. the code you can sequence is any norns lua code. using code you can access any of the standard norns features (midi, osc, crow), and I've also added interfaces to "lite" versions of several of my own scripts (like [*oooooo*](https://llllllll.co/t/oooooo), [supertonic](https://llllllll.co/t/supertonic/), [amen](https://llllllll.co/t/amen/), and [mx.samples](https://llllllll.co/t/mx-samples/)). some basic features of internorns:

- sequence pitches with text, in chords (e.g. `Cm7/Eb`) or notes (e.g. `a4 eb3`)
- sequence midi devices and add cc lfos
- sequence crow with pitches, automatically generating voltage/envelope
- play/rec into three stereo loops via softcut
- built-in drum synth that can be sequenced/modulated in realtime
- built-in sample player that can be quantized
- sequence notes/chords from any instrument in [mx.samples](https://llllllll.co/t/mx-samples/)
- special tape stop / start global fx

internorns works quite simply: it runs an internal sequencer that runs code. there is an internal clock that makes 4 steps per beat, and 4 beats per measure. at each step it checks to see if there is code to run in that step in the current measure and attempts to run it. code can be added to steps using the built-in functions.

see [`data/getting-started.lua`](https://github.com/schollz/internorns/blob/main/data/getting-started.lua) to get started and preview how it works. the process is music.

## Requirements

- computer
- norns
- midi device (optional)
- crow (optional)

## Documentation

start the internorns script on norns.

now choose an editor to live-code, I suggest usig either maiden (in the browser), visual studio code, or vim. instructions for each are below.

<details><summary><strong>maiden</strong></summary>

open up a webbrowser to [http://norns.local/maiden/#edit/dust/data/internorns/getting-started.lua](norns.local/maiden/#edit/dust/data/internorns/getting-started.lua).

you can select any code and press <kbd>ctl</kbd>+<kbd>enter</kbd> to send that code to the norns.

_note:_ requires latest version of maiden.

</details>

<details><summary><strong>visual studio code</strong></summary>

[download visual studio code](https://code.visualstudio.com/) and then install [the Norns REPL extension](https://llllllll.co/t/norns-repl-vscode-extension/41382). use software like [sftp drive](https://www.nsoftware.com/sftp/drive/) to mount your norns on your computer. then you can directly edit `~/dust/data/internorns/getting-started.lua`. 

press <kbd>ctl</kbd>+<kbd>enter</kbd> to send the current line to the norns.

</details>

<details><summary><strong>vim</strong></summary>

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

</details>


open up `dust/data/internorns/getting-started.lua` in your editor to learn how to use internorns.

### Install

make sure you install all of the following (or update if you already have them):

```
;install https://github.com/schollz/mx.samples
;install https://github.com/schollz/supertonic
;install https://github.com/schollz/internorns
```

then restart your norns.

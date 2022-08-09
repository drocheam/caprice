# caprice
## Terminal Frontend for the Caprice Online Radio
 
[Radio Caprice](http://radcap.ru/index-d.html) features over 480 different genres/channels, with this script you can play them all from your terminal.

fzf is used for channel selection and mpv for playback.

The radios.json database is taken from the Radio Caprice Android App.

---
### Installation

Run
```
sudo make install
```

---
### Usage

Call without parameters for the whole genre list:

```
caprice
```

Call with a name to prefilter the channel list:


```
caprice Blues
```

---
### Customization

Change the PLAYER and FINDER variables in the shell script to change the playback and finder tool.


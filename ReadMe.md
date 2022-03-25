# caprice.sh
## Terminal Frontend for the Radio Caprice Online Radio
 
[Radio Caprice](http://radcap.ru/index-d.html) features 480 different genres/channels, with this script you can play them all from your terminal.

fzf is used for channel selection and mpv for playback.

---
### Usage

Call without parameters to select from the whole genre list:

```
caprice
```

Call with name to prefilter channel list:


```
caprice Blues
```

---
### Customization

Change the PLAYER and FINDER variables in the shell script to change the playback and finder tool.

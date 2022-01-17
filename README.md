# SUB 2 TXT

Remove all fluff and leave just the text.

Remove line if

* empty line
* only a number and preceded by an empty line
* timestamp "\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3}"

Use ytdlp

yt-dlp https://www.youtube.com/watch\?v\=NVGuFdX5guE --write-subs --skip-download

https://docs.yt-dlp.org/en/2021.12.27/README.html\#usage-and-options

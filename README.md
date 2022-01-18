# SUB 2 PUB 

Outputs an EPUB of the video's subtitles.

## Usage

```bash
./sub2pub.sh video_url [--auto]
```

* `video_url` - String of the youtube URL. e.g. "https://www.youtube.com/watch?v=NVGuFdX5guE"
* `--auto` (optional) - Uses the auto-generated English captions. Use this if no user made caption exists. (DOES NOT WORK YET)

## Requirements

* I made this in OSX, so you'll need OSX I think
* [Calibre's CLI tools](https://manual.calibre-ebook.com/generated/en/cli-index.html) - Install Calibre and these are installed automatically
* [yt-dlp](https://github.com/yt-dlp/yt-dlp)
* Unix suite of tools (`sed`, `perl` in particular)


#!/bin/zsh

# If no video link as arg, do nothing
if [ $# -eq 0 ]
then
    echo 'No args provided.'
    exit 1
fi

# Set video URL
video_url="$1"
shift

# Set caption type and default lang
type="--write-subs"
lang="en"

while [[ $# -gt 0 ]]; do
    case $1 in
      --auto)
        echo "Auto-generated captions are not supported yet. You're gonna get a mess."
        type="--write-auto-subs"
        shift
        ;;
      --lang)
        lang="$2"
        shift # past argument
        shift # past value
        ;;
      --list-subs)
        yt-dlp "$video_url" --list-subs
        exit 0
    esac
done

# Get video title
title=$(wget -qO- $video_url | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)(?: - youtube)?\s*<\/title/si')
tempfile="$title.$lang.vtt"

# Get the subtitle file
yt-dlp "$video_url" --skip-download $type --sub-langs $lang -o $title

# If file doesn't exist, quit
if [ ! -f $tempfile ]
then
    echo "Captions don't exist. Use --auto to download auto-generated captions."
    exit -1
fi

# Get rid of the header, newlines, number lines, timestamps, fix existing HTML tags, and create paragraph tags after punctuation.
sed -n '5,$p' $tempfile \
    | sed -E '/^[[:digit:]].+-->.+/d' \
    | (sed -E '/^\s*$/d'; echo "\n") \
    | sed -E 's/&lt;/</g' \
    | sed -E 's/&gt;/>/g' \
    | sed 'N;/\n.*<c>/d;P;D' \
    | perl -ne 's/(\n|(\s\s))/ /g; print' \
    | perl -pe 's/([^ ][^ ]..(?:\.|\?|\!)[^\s]*)\s?/\1<\/p>\n<p>/g' \
    > $title.html

# Add preceding paragraph tag at start
echo -e "<h1>$title</h1><p>$(cat $title.html)" > $title.html

# get youtube video hash
img_hash=$(echo $video_url | perl -ne 's/https?:\/\/(www.)?(youtube.com|youtu.be)\/watch\?.*?v=//; print')

# create image url
url_s="https://i.ytimg.com/vi/"
url_e="/maxresdefault.jpg"
img_url="$url_s$img_hash$url_e"

# use calibre to convert to an epub
/Applications/calibre.app/Contents/MacOS/ebook-convert "$title.html" "$title.epub" --cover "$img_url" --title "$title" --comments "$video_url"

# Clean up
rm $tempfile $title.html


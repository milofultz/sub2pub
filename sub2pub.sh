#!/bin/zsh

# If no video link as arg, do nothing
if [ $# -eq 0 ]
then
    echo 'No args.'
    exit 1
fi

# Set caption type
type="--write-subs"

if [ "$2" = "--auto" ]
then
    type="--write-auto-subs"
    echo "Auto-generated captions are not supported yet. You're gonna get a mess."
fi

# Define temp vars
temp="temp"
tempfile="$temp.en.vtt"

# Get video title
title=$(wget -qO- $1 | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)(?: - youtube)?\s*<\/title/si')

# Get the subtitle file
yt-dlp "$1" --skip-download $type -o $temp

# If file doesn't exist, quit
if [ ! -f $tempfile ]
then
    echo "Captions don't exist. Use --auto to download auto-generated captions."
    exit -1
fi

# Get rid of the header, newlines, number lines, timestamps, fix existing HTML tags, and create paragraph tags after punctuation.
sed -n '5,$p' $tempfile \
    | sed -E 's/^[0-9].+-->.+//p' \
    | sed -E '/^\s*$/d' \
    | sed -En '/[^.]$/p' \
    | sed -E 's/&lt;/</g' \
    | sed -E 's/&gt;/>/g' \
    | sed 'N;/\n.*<c>/d;P;D' \
    | perl -ne 's/(\n|(\s\s))/ /g; print' \
    | perl -pe 's/([^ ][^ ]..(?:\.|\?|\!)[^\s]*)\s?/\1<\/p>\n<p>/g' \
    > $temp.html

# Add preceding paragraph tag at start
echo -e "<h1>$title</h1><p>$(cat $temp.html)" > $temp.html

# get youtube video hash
img_hash=$(echo $1 | perl -ne 's/https?:\/\/(www.)?(youtube.com|youtu.be)\/watch\?.*?v=//; print')

# create image url
url_s="https://i.ytimg.com/vi/"
url_e="/maxresdefault.jpg"
img_url=$url_s$img_hash$url_e

# use calibre to convert to an epub
/Applications/calibre.app/Contents/MacOS/ebook-convert $temp.html $title.epub --cover $img_url --title $title --comments $1

# Clean up
rm $tempfile $temp.html


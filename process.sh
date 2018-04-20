#!/bin/bash

clear

echo "Starting processing"

watch_dir="/watch"
process_dir="/process"
output_dir="/output"
error_dir="/error"
archive_dir="/archive"

filetypes=( "**/*.avi" "**/*.mkv" "**/*.mp4" "**/*.m4v" )
videocodecs=( "h264" )
#videocodecs=( "h264" "h265" "hevc" )
audiocodecs=( "aac" "ac3" )
#audiocodecs=( "aac" "ac3" "mp3" )

# Disable case sensitivity
shopt -s nocaseglob
shopt -s globstar

# move everything to the processing directory
echo "moving files to process directory"
mv $watch_dir/* $process_dir/

  cd "$process_dir"  
  for i in ${filetypes[*]}; do
    in_file=$(readlink -m "$i")
    in_filename=`basename "$in_file"`
    in_filename_wo_ext="${in_filename%.*}"
  
    if [ "$in_filename_wo_ext" == "*" ]; then
      continue  
    fi

    in_file_ext="${in_filename##*.}"
    out_filename="$in_filename_wo_ext".mp4
    vconvert='libx264'
    aconvert='aac -strict experimental'

    for vcodec in ${videocodecs[*]}; do
      if ffprobe -show_streams -loglevel quiet "$in_file" | grep "$vcodec"; then
        vconvert='copy'
      fi
    done  
 
    for acodec in ${audiocodecs[*]}; do
      if ffprobe -show_streams -loglevel quiet "$in_file" | grep "$acodec"; then
        aconvert='copy'
      fi
    done
  
    echo "Video convert: $vconvert"
    echo "Audio convert: $aconvert"

    echo "Starting conversion of $in_filename"
    ffmpeg -y -i "$in_file" -c:v "$vconvert" -c:a "$aconvert" -flags global_header -map_metadata -1 "$output_dir"/"$out_filename"
    if [ "$?" -eq 0 ];
      then
        echo "Sucessfully converted $in_file"
        mv "$in_file" "$archive_dir/"
      else
        echo "Error converting $in_file"
        mv "$in_file" "$error_dir/"
    fi

  done

echo "Finished processing"

# clean up processing directory
echo "Cleaning up process directory"
rm -rf $process_dir/*

shopt -u nocaseglob
exit 0;

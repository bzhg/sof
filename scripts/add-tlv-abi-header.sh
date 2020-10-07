#!/bin/bash

set -e

OUTPUT_DIR=output_blobs
COMP_SPECIFIC_TYPE=0

mkdir $OUTPUT_DIR
for file in "$@"; do
	SIZE=$(stat -c %s "$file")
	FILE_NAME=$(basename -- "$file")
	echo $SIZE "$FILE_NAME"
	./tools/build_tools/ctl/sof-ctl -t $COMP_SPECIFIC_TYPE -a $SIZE -o $OUTPUT_DIR/header.bin
	cat $OUTPUT_DIR/header.bin "$file" > "$OUTPUT_DIR/$FILE_NAME.bin"
done
rm $OUTPUT_DIR/header.bin

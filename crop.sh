#!/bin/bash

cd tiff/ || return
sizex=$(($3 - $1))
sizey=$(($4 - $2))
for file in *
do
    # widthxheight+left+top 裁剪后的size 然后是左上角坐标
    convert "$file" -crop ${sizex}x${sizey}+$1+$2 "../crop/$file"
done

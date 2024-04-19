# 中文pdf书籍OCR流程

## 处理过程

1. 把指定pdf提取为图片（会自动加编号）

    `pdfimages -tiff -j target.pdf tiff/tg`

    提取出来的文件如果不是tif后缀，一般意味着这一页是图片，有文字以外的信息，需要特殊处理。

2. 裁剪，尽量排除上下左右的内容/标题和页码；注意有时候奇数页和偶数页不一致，需要分开处理。不裁剪的话，后面要自己到文本里面一个一个处理，费时间。

    `./crop.sh i j k l`

    需要四个整数，(i j), (k l)分别是左上角和右下角的坐标。

3. 把要ocr的图片写入到一个list

    `ls tiff/*.tif > list.txt`

4. 用tesseract来OCR，结果保存到result.txt

    `tesseract list.txt result -l chi_sim`

    （繁体 chi_tra）

5. 处理文本

    `sed -f sed result.txt > resultsed.txt`

    删除空格，区分出段落，删除不需要的换行，英文标点替换为中文标点符号。引号未处理，因为引号极容易识别成一些乱七八糟的东西，而标记脚注的数字容易被识别成引号。

6. 合并行 & 添加空行

    `sed -z 's/\(.\)\n/\1/g' resultsed.txt | sed 'G' > result.md`

    （一个段落占一行，前后都有空行，所以用markdown格式）
    
7. 添加metadata和章节结构。把下面文本复制到result.md的最开始，并填入相应信息。补充缺失的图片内容，将最初提取的图片适当裁剪，保存成文件并在md文件里面引用。  
```text
---
title: 
author: 
publisher: 
date: 
---
```

8. 校对。对画面较好的pdf，准确率是相当高，但即使这样，错误的绝对数量总是很大。对画面差的，先

9. 经过校对的文本转成epub分享。epub优点：略小的文件体积，一个文件，可应用样式。而直接md文件适合编辑修改。

    `pandoc -o final.epub result.md --table-of-contents --css style.css`

10. 简繁转化（顺序上不是这个位置，只是提醒有这么个工具）

    `opencc -i resultsed.txt -c t2s.json -o resultsed_sim.txt`

    -i input, -o output, -c 预设配置文件 `t2s.json` Traditional Chinese to Simplified Chinese，这是内置的配置文件，也可以指定到自己写的配置文件

## 理想中要做的处理或面临的问题

- 引号和脚注

- 减少识别错误，尤其画质很差的pdf识别效果很糟糕，需要一种处理，让那种残缺的文字的线条变完整

- tesseract经常莫名其妙插入“和”字

- OCR输出结果最好能标记那些很可能出错的字

- 中文语法语义分析，词语及词频统计，标点符号用法是否正确。

- 汉字相似性判别

- 自动判断页眉/页脚/边注/底部注释的位置


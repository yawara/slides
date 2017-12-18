#!/bin/bash
pandoc -V theme=white -t revealjs --mathjax -s -o ${1/md/html} -c ${1/md/css} $1
#pandoc -t revealjs --mathjax -s -o ${1/md/html} -c ${1/md/css} $1


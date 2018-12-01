#!/bin/sh

pandoc --css highlight.css --filter vim-highlight.pl $@

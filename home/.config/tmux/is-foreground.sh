#!/bin/sh
# Match only live foreground jobs, including pipeline members whose leader exited.
ps -o stat=,comm= -t "$1" |
  awk -v pattern="^($2)$" '
    $1 ~ /\+/ && $1 !~ /^[TXZ]/ && $2 ~ pattern { found = 1 }
    END { exit !found }
  '

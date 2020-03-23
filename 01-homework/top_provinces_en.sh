#!/bin/bash

cut -d, -f1 province.csv | xargs -I {} bash -c "grep -iw {} <(join -t, -1 1 -2 3 <(sort -t, -k1 spread.csv) <(sort -t, -k3 <(join -t, -1 1 -2 2 <(sort -t, -k1 province.csv) <(sort -t, -k2 city_province.csv)))) | awk -F, '{r+=\$3;d+=\$4} END {print \$5\" (\"\$NF\"): \"int((d/r)*1000)}' " | sort -t: -rnk2 | head

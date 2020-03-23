#!/bin/bash

cut -d, -f1 province.csv | xargs -I {} bash -c "grep -iw {} <(join -t, -j 1 <(sort -t, -k1 spread.csv) <(sort -t, -k1 city_province.csv)) | awk -F, '{r+=\$3;d+=\$4} END {print \$NF\": \"int((d/r)*1000)}' " | sort -t: -rnk2 | head
#!/bin/bash

awk -F, '$4 > 100 {print $1" ("$2"): "int(($5/$4)*1000)}' <(join -t, -j 1 <(sort -t, -k1 city.csv) <(sort -t, -k1 spread.csv)) | sort -t: -rnk2 | head 
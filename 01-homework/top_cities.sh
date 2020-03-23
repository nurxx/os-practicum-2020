#!/bin/bash

awk -F, '$3 > 100 { print $1": "int(($4/$3)*1000) }' spread.csv | sort -t: -rnk2 | head
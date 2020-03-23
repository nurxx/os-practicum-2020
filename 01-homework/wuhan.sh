#!/bin/bash

awk -F, '{print $NF}'  <(grep -iw "$(awk -F, '$2 == "Wuhan" {print $1}' city.csv)" spread.csv)


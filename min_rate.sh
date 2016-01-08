#!/bin/bash

source config.cfg

file=../"$title"_"$4"/rates/$1-$2-$3

min_rate=$(awk 'BEGIN {min=99999999999999; rate=0}; {if (min > $2) {min=$2; rate=$1};}; END{print rate}' $file) 

echo $min_rate

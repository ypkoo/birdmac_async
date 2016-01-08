#!/bin/bash

source config.cfg

period=$1
timeout=$(expr $period \* 30 \* 1000)

echo "period="$period"
sigma="$2"
topology="$3"
seed="$4"
check_rate="$5"
density="$6"
mac="$7"
home_dir=~/home2/birdmac_async/$7/lanada/app
result_dir="$title"_"$7"
rawdata_dir="$title"_"$7"/rawdata
timeout="$timeout"" > var_config.cfg

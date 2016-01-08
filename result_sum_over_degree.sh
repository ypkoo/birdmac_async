#!/bin/bash

source config.cfg

for mac in "${macs[@]}"; do
	result_dir="$title"_"$mac"
	rawdata_dir="$result_dir"/rawdata

	rm -f ../$result_dir/over_rate
	for period in "${periods[@]}"; do
	  for sigma in "${sigmas[@]}"; do
	    for density in "${densities[@]}"; do
				for topology in "${topologies[@]}"; do
					check_rate=$(./min_rate.sh $period $topology $density $mac)
					rm -f temp_power
					filename=$period-$topology-$check_rate-$density

					cycle_num=$(awk 'BEGIN {max=0}; {if (max < $3) {max=$3};}; END{print max}' ../$rawdata_dir/$filename-1-result)
					node_num=$(awk 'BEGIN {max=0}; {if (max < $2) {max=$2};}; END{print max}' ../$rawdata_dir/$filename-1-result)
		    	for seed in "${seeds[@]}"; do
						awk -v cycle="$cycle_num" '{ontime_sum+=$5} END{print ontime_sum/cycle}' < ../$rawdata_dir/$period-$topology-$check_rate-$density-$seed-result >> temp_power
		      done

					awk -v t="$topology" '{sum+=$1}; END {printf "%-3d%-10.3f\n", t, sum/NR}' temp_power >> ../$result_dir/$period-$density-sum
					awk -v t="$topology" -v n="$node_num" '{sum+=$1}; END {printf "%-3d%-10.3f\n", t, sum/(NR*n)}' temp_power >> ../$result_dir/$period-$density-avg
					rm -f temp_power


	      done
	    done
	  done
	done
done

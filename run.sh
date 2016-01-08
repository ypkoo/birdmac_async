#!/bin/bash

source config.cfg
for mac in "${macs[@]}"; do
	rm -rf ../"$title"_"$mac"
done

for mac in "${macs[@]}"; do
	mkdir -p ../"$title"_"$mac"
	mkdir -p ../"$title"_"$mac"/results
	mkdir -p ../"$title"_"$mac"/rawdata
	cat config.cfg > ../"$title"_"$mac"/config.cfg
	for period in "${periods[@]}"; do
	  for topology in "${topologies[@]}"; do
	    for check_rate in "${check_rates[@]}"; do
	      for sigma in "${sigmas[@]}"; do
					for density in "${densities[@]}"; do
						for seed in "${seeds[@]}"; do
							./var_config.sh $period $sigma $topology $seed $check_rate $density $mac
							cat var_config.cfg
							./do_simulation.sh
						done
					done
	      done
	    done
	  done
	done
done

rm COOJA.log
rm COOJA.testlog
rm -rf se

#./result_power.sh
#./result_stat.sh

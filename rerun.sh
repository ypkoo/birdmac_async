#!/bin/bash

source config.cfg

for mac in "${macs[@]}"; do
	for period in "${periods[@]}"; do
	  for topology in "${topologies[@]}"; do
	    for check_rate in "${check_rates[@]}"; do
	      for sigma in "${sigmas[@]}"; do
					for density in "${densities[@]}"; do
						for seed in "${seeds[@]}"; do
							if [ ! -f ../"$title"_"$mac"/rawdata/$period-$topology-$check_rate-$density-$seed-power ]; then
								./var_config.sh $period $sigma $topology $seed $check_rate $density $mac
								cat var_config.cfg
								./do_simulation.sh
							fi
						done
					done
	      done
	    done
	  done
	done
done

rm -f COOJA.log
rm -f COOJA.testlog
rm -rf se

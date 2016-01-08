#!/bin/bash

source config.cfg

for mac in "${macs[@]}"; do
	result_dir="$title"_"$mac"
	rawdata_dir="$result_dir"/rawdata
	mkdir -p ../$result_dir/rates
	rm -f ../$result_dir/rates/*
	rm -f ../$result_dir/min_results/*
	files=$(ls ../$rawdata_dir/*result)

	for file in $files; do
		grep "\[data\]" $file > temp
		cat temp > $file
		rm temp
	done
done

for mac in "${macs[@]}"; do
	result_dir="$title"_"$mac"
	rawdata_dir="$result_dir"/rawdata

	rm -f ../$result_dir/over_rate
	for period in "${periods[@]}"; do
	  for sigma in "${sigmas[@]}"; do
	    for density in "${densities[@]}"; do
				for topology in "${topologies[@]}"; do
					for check_rate in "${check_rates[@]}"; do
						rm -f temp_power
			    	for seed in "${seeds[@]}"; do
							if [ -f ../$rawdata_dir/$period-$topology-$check_rate-$density-$seed-power ]; then
								grep "AVG ON" ../$rawdata_dir/$period-$topology-$check_rate-$density-$seed-power >> temp_power
							fi
			      done
						awk -v rate="$check_rate" '{sum+=$3}; END {printf "%-4d%-10.3f\n", rate, sum/NR}' temp_power >> ../$result_dir/rates/$period-$topology-$density
						rm -f temp_power
					done
	      done
	    done
	  done
	done
done

for mac in "${macs[@]}"; do
	result_dir="$title"_"$mac"
	rawdata_dir="$result_dir"/rawdata
	rm -f ../$result_dir/over_period
	for topology in "${topologies[@]}"; do
	  for sigma in "${sigmas[@]}"; do
	    for density in "${densities[@]}"; do
				
				echo "# topology" $topology >> ../$result_dir/over_period
				for period in "${periods[@]}"; do
					check_rate=$(./min_rate.sh $period $topology $density $mac)
					rm -f temp_power
			    for seed in "${seeds[@]}"; do
		      	grep "AVG ON" ../$rawdata_dir/$period-$topology-$check_rate-$density-$seed-power >> temp_power
			    done
					awk -v period="$period" -v rate="$check_rate" '{sum+=$3}; END {printf "%-4d%-10.3f # %d\n", period, sum/NR, rate}' temp_power >> ../$result_dir/over_period
					rm -f temp_power
				done
				echo "" >> ../$result_dir/over_period
	    done
	  done
	done
done

for mac in "${macs[@]}"; do
	result_dir="$title"_"$mac"
	rawdata_dir="$result_dir"/rawdata
	rm -f ../$result_dir/over_degree
	for period in "${periods[@]}"; do
	  for sigma in "${sigmas[@]}"; do
	    for density in "${densities[@]}"; do
				echo "# period" $period >> ../$result_dir/over_degree
				for topology in "${topologies[@]}"; do
					check_rate=$(./min_rate.sh $period $topology $density $mac)
					rm -f temp_power
	      	for seed in "${seeds[@]}"; do
						grep "AVG ON" ../$rawdata_dir/$period-$topology-$check_rate-$density-$seed-power >> temp_power
	        done
					awk -v degree="$topology" -v rate="$check_rate" '{sum+=$3}; END {printf "%-4d%-10.3f # %d\n", degree, sum/NR, rate}' temp_power >> ../$result_dir/over_degree
					rm -f temp_power
	      done
				echo "" >> ../$result_dir/over_degree
	    done
	  done
	done
done


for mac in "${macs[@]}"; do
	result_dir=../"$title"_"$mac"
	rawdata_dir="$result_dir"/rawdata
	for period in "${periods[@]}"; do
	  for topology in "${topologies[@]}"; do
	    for check_rate in "${check_rates[@]}"; do
	      for sigma in "${sigmas[@]}"; do
					for density in "${densities[@]}"; do
						for seed in "${seeds[@]}"; do
							filename=$period-$topology-$check_rate-$density-$seed
							if [ -f $rawdata_dir/$filename-result ]; then
								cycle_num=$(awk 'BEGIN {max=0}; {if (max < $3) {max=$3};}; END{print max}' $rawdata_dir/$filename-result)
								node_num=$(awk 'BEGIN {max=0}; {if (max < $2) {max=$2};}; END{print max}' $rawdata_dir/$filename-result)
							
								# CHILD + PARENT
								printf "" > $result_dir/results/$filename
								for (( i=1; i<=$node_num; i++ )); do
		  						awk -v i="$i" -v cycle_num="$cycle_num" -v node_num="$node_num" '{
											if ($2==i) 
											{
												if ($4=="PARENT") {sum_ontime_p+=$5; sum_rb_p+=$6; sum_rm_p+=$7; sum_f_p+=$8; sum_r_p+=$9; sum_bs_p+=$11;}
												else if ($4=="CHILD") {sum_ontime_c+=$5; sum_rb_c+=$6; sum_rm_c+=$7; sum_f_c+=$8; sum_r_c+=$9; sum_bs_c+=$11;};
											};};
											END {
											print i, sum_ontime_p/cycle_num, sum_rb_p/cycle_num, sum_rm_p/cycle_num, sum_f_p/cycle_num, sum_r_p/cycle_num, sum_bs_p/cycle_num, sum_ontime_c/cycle_num, sum_rb_c/cycle_num, sum_rm_c/cycle_num, sum_f_c/cycle_num, sum_r_c/cycle_num, sum_bs_c/cycle_num;}' $rawdata_dir/$filename-result >> $result_dir/results/$filename
								done
							fi
						done
						filename=$period-$topology-$check_rate-$density
						#node_num=$(awk 'BEGIN {max=0}; {if (max < $2) {max=$2};}; END{print max}' $rawdata_dir/$filename-1-result)
						file_list=$(ls $result_dir/results/$filename-*)
						
						rm -f temp
						for file in $file_list; do
							cat $file >> temp
							rm -f $file
						done	

						for (( i=1; i<=$node_num; i++ )); do
							awk -v i="$i" '{
								if ($1==i) {sum2+=$2; sum3+=$3; sum4+=$4; sum5+=$5; sum6+=$6; sum7+=$7; sum8+=$8; sum9+=$9; sum10+=$10; sum11+=$11; sum12+=$12; sum13+=$13; n++}}
								END {print i, sum2/n, sum3/n, sum4/n, sum5/n, sum6/n, sum7/n, sum8/n, sum9/n, sum10/n, sum11/n, sum12/n, sum13/n, n;}' temp >> $result_dir/results/$filename
						done
						rm -f temp						

						awk '{print $1, $2+$8}' $result_dir/results/$filename > $result_dir/results/ontime-$filename
						awk '{print $1, $3+$9}' $result_dir/results/$filename > $result_dir/results/rb-$filename
						awk '{print $1, $4+$10}' $result_dir/results/$filename > $result_dir/results/rm-$filename
						awk '{print $1, $5+$11}' $result_dir/results/$filename > $result_dir/results/f-$filename
						awk '{print $1, $6+$12}' $result_dir/results/$filename > $result_dir/results/r-$filename
						awk '{print $1, $7+$13}' $result_dir/results/$filename > $result_dir/results/bs-$filename

						awk '{print $1, $2}' $result_dir/results/$filename > $result_dir/results/ontime-$filename-par
						awk '{print $1, $3}' $result_dir/results/$filename > $result_dir/results/rb-$filename-par
						awk '{print $1, $4}' $result_dir/results/$filename > $result_dir/results/rm-$filename-par
						awk '{print $1, $5}' $result_dir/results/$filename > $result_dir/results/f-$filename-par
						awk '{print $1, $6}' $result_dir/results/$filename > $result_dir/results/r-$filename-par
						awk '{print $1, $7}' $result_dir/results/$filename > $result_dir/results/bs-$filename-par

						awk '{print $1, $8}' $result_dir/results/$filename > $result_dir/results/ontime-$filename-chi
						awk '{print $1, $9}' $result_dir/results/$filename > $result_dir/results/rb-$filename-chi
						awk '{print $1, $10}' $result_dir/results/$filename > $result_dir/results/rm-$filename-chi
						awk '{print $1, $11}' $result_dir/results/$filename > $result_dir/results/f-$filename-chi
						awk '{print $1, $12}' $result_dir/results/$filename > $result_dir/results/r-$filename-chi
						awk '{print $1, $13}' $result_dir/results/$filename > $result_dir/results/bs-$filename-chi
					done
	      done
	    done
	  done
	done
done


for mac in "${macs[@]}"; do
	result_dir="$title"_"$mac"
	rawdata_dir="$result_dir"/rawdata

	mkdir -p ../$result_dir/min_results
	for period in "${periods[@]}"; do
	  for sigma in "${sigmas[@]}"; do
	    for density in "${densities[@]}"; do
				for topology in "${topologies[@]}"; do
					min_rate=$(./min_rate.sh $period $topology $density $mac)
					cp ../$result_dir/results/$period-$topology-$min_rate-$density ../$result_dir/min_results/
					cp ../$result_dir/results/bs-$period-$topology-$min_rate-$density ../$result_dir/min_results/
					cp ../$result_dir/results/ontime-$period-$topology-$min_rate-$density ../$result_dir/min_results/
					cp ../$result_dir/results/rm-$period-$topology-$min_rate-$density ../$result_dir/min_results/
					cp ../$result_dir/results/r-$period-$topology-$min_rate-$density ../$result_dir/min_results/
					cp ../$result_dir/results/f-$period-$topology-$min_rate-$density ../$result_dir/min_results/
	      done
	    done
	  done
	done
done



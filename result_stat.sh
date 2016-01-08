#!/bin/bash

source config.cfg

id_idx=2
cycle_idx=3
mode_idx=4
ontime_idx=5
rb_idx=6
rm_idx=7
f_idx=8
r_idx=9
drift_idx=10

# remove useless lines
for mac in "${macs[@]}"; do
	result_dir=../"$title"_"$mac"
	rawdata_dir="$result_dir"/rawdata
	files=$(ls $rawdata_dir/*result)

	rm -f $result_dir/results/*

	for file in $files; do
		grep "\[data\]" $file > temp
		cat temp > $file
		rm temp
	done
done

for mac in "${macs[@]}"; do
	result_dir=../"$title"_"$mac"
	rawdata_dir="$result_dir"/rawdata
	for period_ in "${periods[@]}"; do
		period=$(expr $period_ \* 3600)
	  for topology in "${topologies[@]}"; do
	    for check_rate in "${check_rates[@]}"; do
	      for sigma in "${sigmas[@]}"; do
					for density in "${densities[@]}"; do
						for seed in "${seeds[@]}"; do
							filename=$period-$topology-$check_rate-$density-$seed
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


						done
						filename=$period-$topology-$check_rate-$density
						node_num=$(awk 'BEGIN {max=0}; {if (max < $2) {max=$2};}; END{print max}' $rawdata_dir/$filename-1-result)
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





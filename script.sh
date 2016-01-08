#!/bin/bash

source var_config.cfg

cat sim_scripts/script$topology-1 > simulation.csc

echo "TIMEOUT($timeout);&#xD;
output1 = new FileWriter(\"../$rawdata_dir/$period-$topology-$check_rate-$density-$seed-result\");&#xD;
output2 = new FileWriter(\"../$rawdata_dir/$period-$topology-$check_rate-$density-$seed-power\");&#xD;
plugin = mote.getSimulation().getGUI().getStartedPlugin(\"PowerTracker\");&#xD;
&#xD;
while (true) {&#xD;
  output1.write(msg + \"\n\");&#xD;
  log.log(time + \":\" + id + \":\" + msg + \"\n\");&#xD;
  try{&#xD;
    YIELD();&#xD;
  } catch (e) {&#xD;
    stats = plugin.radioStatistics();&#xD;
    output2.write(stats + \"\n\");&#xD;
    output1.close();&#xD;
    output2.close();&#xD;
    throw('test script killed')&#xD;
  }&#xD;" >> simulation.csc

cat sim_scripts/script$topology-2 >> simulation.csc

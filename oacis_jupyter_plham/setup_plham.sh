#!/bin/bash

plham_home=/home/oacis/plham
source_path=$plham_home/samples/CI2002/CI2002Main.x10
binary_path=~/bin/plham/bin/CI2002.out
runner_path=$plham_home/samples/CI2002/oacis/run.sh
analyzer_path=$plham_home/samples/CI2002/oacis/plot.sh

# download plham
git clone https://github.com/plham/plham.git $plham_home
mkdir ~/oacis/public/Result_development/plham
cp -r $plham_home/etc/seminar ~/oacis/public/Result_development/plham/
chmod +x $runner_path
chmod +x $analyzer_path

# build binary
mkdir -p `dirname $binary_path`
x10c++ -sourcepath $plham_home $source_path -d build -o $binary_path
## clean up
rm -rf build

# install to OACIS
db_name=oacis_development
host_object_id=`mongo $db_name --eval "db.hosts.find({\"name\":\"localhost\"}).forEach(function(obj){ print(obj[\"_id\"]); })" | tail -1`
host_id=${host_object_id%\")}
host_id=${host_id#ObjectId(\"}
echo "[{\"id\": \"$host_id\"}]" > host.json

echo "{
  \"name\": \"Plham_CI2002\",
  \"command\": \"$runner_path\",
  \"support_input_json\": false,
  \"support_mpi\": false,
  \"support_omp\": false,
  \"print_version_command\": \"cd $plham_home; git describe --always\",
  \"pre_process_script\": null,
  \"executable_on_ids\": [],
  \"description\":\"### CI2002Main\\r\\n\\r\\n- [Visit developer site](https://github.com/plham/plham)\",
  \"parameter_definitions\": [
    {\"key\": \"executable\",\"type\": \"String\",\"default\": \"$binary_path\",\"description\": \"\"},
    {\"key\": \"fundamentalWeight\",\"type\": \"Float\",\"default\": 1.0,\"description\": \"\"},
    {\"key\": \"chartWeight\",\"type\": \"Float\",\"default\": 0.0,\"description\": \"\"},
    {\"key\": \"noiseWeight\",\"type\": \"Float\",\"default\": 1.0,\"description\": \"\"}
  ]
}
" > simulator1.json

~/oacis/bin/oacis_cli create_simulator -h host.json -i simulator1.json -o simulator1_id.json
echo "{
  \"name\" : \"Timeseries_Plot\",
  \"type\" : \"on_run\",
  \"auto_run\" : \"no\",
  \"files_to_copy\" : \"_stdout.txt\",
  \"description\":\"make a timeseries plot\",
  \"command\" : \"$analyzer_path\",
  \"support_input_json\" : false,
  \"support_mpi\" : false,
  \"support_omp\" : false,
  \"print_version_command\" : \"cd $plham_home; git describe --always\",
  \"pre_process_script\" : null,
  \"executable_on_ids\": [],
  \"parameter_definitions\": [
    {\"key\": \"FileName\",\"type\": \"String\",\"default\": \"output.png\",\"description\": \"\"}
  ]
}
" > analyzer1.json
~/oacis/bin/oacis_cli create_analyzer -h host.json -s simulator1_id.json -i analyzer1.json -o analyzer1_id.json

echo "{
  \"name\": \"Plham_Seminar02\",
  \"command\": \"bash ~/oacis/public/Result_development/plham/seminar/oacis/run.sh ~/CI2002.exe\",
  \"support_input_json\": false,
  \"support_mpi\": false,
  \"support_omp\": false,
  \"print_version_command\": \"\",
  \"pre_process_script\": null,
  \"executable_on_ids\": [],
  \"description\":\"\",
  \"parameter_definitions\": [
    {\"key\": \"fundamentalWeight\",\"type\": \"Float\",\"default\": 1.0,\"description\": \"\"},
    {\"key\": \"chartWeight\",\"type\": \"Float\",\"default\": 0.0,\"description\": \"\"},
    {\"key\": \"noiseWeight\",\"type\": \"Float\",\"default\": 1.0,\"description\": \"\"}
  ]
}
" > simulator2.json

~/oacis/bin/oacis_cli create_simulator -h host.json -i simulator2.json -o simulator2_id.json
echo "{
  \"name\" : \"Timeseries_Plot\",
  \"type\" : \"on_run\",
  \"auto_run\" : \"yes\",
  \"files_to_copy\" : \"*\",
  \"description\":\"\",
  \"command\" : \"Rscript ~/oacis/public/Result_development/plham/seminar/plot.R _input/_stdout.txt plot.png\",
  \"support_input_json\" : false,
  \"support_mpi\" : false,
  \"support_omp\" : false,
  \"print_version_command\" : \"\",
  \"pre_process_script\" : null,
  \"executable_on_ids\": [],
  \"parameter_definitions\": [
  ]
}
" > analyzer2.json
~/oacis/bin/oacis_cli create_analyzer -h host.json -s simulator2_id.json -i analyzer2.json -o analyzer2_id.json

echo "{
  \"name\" : \"Fattail_Plot\",
  \"type\" : \"on_run\",
  \"auto_run\" : \"yes\",
  \"files_to_copy\" : \"*\",
  \"description\":\"\",
  \"command\" : \"Rscript ~/oacis/public/Result_development/plham/seminar/fattail.R _input/_stdout.txt fattail.png\",
  \"support_input_json\" : false,
  \"support_mpi\" : false,
  \"support_omp\" : false,
  \"print_version_command\" : \"\",
  \"pre_process_script\" : null,
  \"executable_on_ids\": [],
  \"parameter_definitions\": [
  ]
}
" > analyzer3.json
~/oacis/bin/oacis_cli create_analyzer -h host.json -s simulator2_id.json -i analyzer3.json -o analyzer3_id.json

echo "{
  \"name\" : \"Volcluster_Plot\",
  \"type\" : \"on_run\",
  \"auto_run\" : \"yes\",
  \"files_to_copy\" : \"*\",
  \"description\":\"\",
  \"command\" : \"Rscript ~/oacis/public/Result_development/plham/seminar/volcluster.R _input/_stdout.txt volcluster.png\",
  \"support_input_json\" : false,
  \"support_mpi\" : false,
  \"support_omp\" : false,
  \"print_version_command\" : \"\",
  \"pre_process_script\" : null,
  \"executable_on_ids\": [],
  \"parameter_definitions\": [
  ]
}
" > analyzer4.json
~/oacis/bin/oacis_cli create_analyzer -h host.json -s simulator2_id.json -i analyzer4.json -o analyzer4_id.json

echo "{
  \"name\" : \"Statistics\",
  \"type\" : \"on_run\",
  \"auto_run\" : \"yes\",
  \"files_to_copy\" : \"*\",
  \"description\":\"\",
  \"command\" : \"Rscript ~/oacis/public/Result_development/plham/seminar/statistics.R _input/_stdout.txt >_output.json\",
  \"support_input_json\" : false,
  \"support_mpi\" : false,
  \"support_omp\" : false,
  \"print_version_command\" : \"\",
  \"pre_process_script\" : null,
  \"executable_on_ids\": [],
  \"parameter_definitions\": [
  ]
}
" > analyzer5.json
~/oacis/bin/oacis_cli create_analyzer -h host.json -s simulator2_id.json -i analyzer5.json -o analyzer5_id.json

## clean up
rm host.json \
simulator1.json \
simulator1_id.json \
analyzer1.json \
analyzer1_id.json \
simulator2.json \
simulator2_id.json \
analyzer2.json \
analyzer2_id.json \
analyzer3.json \
analyzer3_id.json \
analyzer4.json \
analyzer4_id.json \
analyzer5.json \
analyzer5_id.json

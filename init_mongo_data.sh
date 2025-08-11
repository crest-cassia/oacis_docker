#/bin/bash

db_name=oacis_development
if [ "$(mongosh ${db_name} --eval 'printjson(db.hosts.count({"name": "localhost"}));' | tail -1 | tr -d '\r')" == "0" ]
then
  mongosh ${db_name} --eval 'db.hosts.insert({"status" : "enabled", "work_base_dir" : "~/oacis/public/Result_development/work/__work__", "mounted_work_base_dir" : "~/oacis/public/Result_development/work/__work__", "max_num_jobs" : 4, "polling_interval" : 5, "min_mpi_procs" : 1, "max_mpi_procs" : 1, "min_omp_threads" : 1, "max_omp_threads" : 1, "name" : "localhost"})'
fi
if [ "$(mongosh ${db_name} --eval 'printjson(db.hosts.count({"name": "docker-host"}));' | tail -1 | tr -d '\r')" == "0" ]
then
  mongosh ${db_name} --eval 'db.hosts.insert({"status" : "enabled", "work_base_dir" : "~/oacis_work", "mounted_work_base_dir" : "", "max_num_jobs" : 1, "polling_interval" : 5, "min_mpi_procs" : 1, "max_mpi_procs" : 1, "min_omp_threads" : 1, "max_omp_threads" : 1, "name" : "docker-host"})'
fi

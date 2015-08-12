module Xsub

  class SchedulerSR16000 < Base

    TEMPLATE = <<'EOS'
#!/bin/bash -x
#@class = <%= job_class %>
#@job_type = parallel
#@network.MPI=sn_single,,US,,instances=1
#@bulkxfer=yes
#@node = <%= mpi_procs / 64 %>
#@tasks_per_node = 64
#@resources = ConsumableCpus(1)
#@output = $(host).$(jobid).stdout
#@error = $(host).$(jobid).stderr
#@queue

# unlimit
export MEMORY_AFFINITY=MCM
export MP_SHARED_MEMORY=no
export HF_PRUNST_THREADNUM=1
export XLSMPOPTS="spins=0:yields=0:parthds=1"

. <%= job_file %>
EOS

    PARAMETERS = {
      "mpi_procs" => { description: "MPI process", default: 1, format: '^[1-9]\d*$'},
      "omp_threads" => { description: "OMP threads", default: 1, format: '^[1-9]\d*$'},
      "job_class" => { description: "Job class", default: "c"},
    }

    def validate_parameters(prm)
      mpi = prm["mpi_procs"].to_i
      omp = prm["omp_threads"].to_i
      unless mpi >= 1 and omp >= 1
        raise "mpi_procs and omp_threads must be larger than or equal to 1"
      end
      unless mpi % 64 == 0
        raise "mpi_procs must be a multiple of 64"
      end
    end

    def submit_job(script_path)
      FileUtils.mkdir_p(@work_dir)

      cmd = "cd #{File.expand_path(@work_dir)} && llsubmit #{File.expand_path(script_path)}"
      @logger.info "cmd: #{cmd}"
      output = `#{cmd}`
      raise "rc is not zero: #{output}" unless $?.to_i == 0
      # sample output:
      #   KBGT60003-I Budget function authenticated bu0701. bu0701 is not assigned account number.
      #   llsubmit: The job "htcf02c01p02.134491" has been submitted.
      regexp = /^llsubmit: The job "(\w+.\d+)" has been submitted.$/
      matched_line = output.lines.find {|line| line =~ regexp }
      if matched_line
        job_id = $1
      else
        @logger.error "unexpected format"
        raise "unexpected format"
      end
      @logger.info "job_id: #{job_id}"
      {job_id: job_id, raw_output: output.lines.map(&:chomp).to_a }
    end

    def status(job_id)
      cmd = "llq #{job_id}"
      ## sample output
      # Id                       Owner      Submitted   ST PRI Class        Running On 
      # ------------------------ ---------- ----------- -- --- ------------ -----------
      # htcf02c01p02.134491.0    bu0701      8/15 14:37 I  50  c                       
      #
      # 1 job step(s) in query, 1 waiting, 0 pending, 0 running, 0 held, 0 preempted

      output = `#{cmd}`
      if $?.to_i == 0
        status = case output.lines.to_a[2].split[4]
        when "I","NQ"
          :queued
        when "R"
          :running
        else
          :finished
        end
      else
        status = :finished
      end
      { status: status, raw_output: output.lines.map(&:chomp).to_a }
    end

    def all_status
      cmd = "llq"
      output = `#{cmd}`
      { raw_output: output.lines.map(&:chomp).to_a }
    end

    def delete(job_id)
      cmd = "llcancel #{job_id}"
      output = `#{cmd}`
      output = "llcancel failed: rc=#{$?.to_i}" unless $?.to_i == 0
      {raw_output: output.lines.map(&:chomp).to_a }
    end
  end
end

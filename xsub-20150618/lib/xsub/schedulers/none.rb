module Xsub

  class SchedulerNone < Base

    TEMPLATE = <<EOS
. <%= job_file %>
EOS

    PARAMETERS = {
      "mpi_procs" => { description: "MPI process", default: 1, format: '^[1-9]\d*$'},
      "omp_threads" => { description: "OMP threads", default: 1, format: '^[1-9]\d*$'}
    }

    def submit_job(script_path)
      full_path = File.expand_path(script_path)
      cmd = "nohup bash #{full_path} > /dev/null 2>&1 < /dev/null & echo $!"
      @logger.info "#{cmd} is invoked"
      output = ""
      FileUtils.mkdir_p(@work_dir)
      Dir.chdir(@work_dir) {
        output = `#{cmd}`
        raise "rc is not zero: #{cmd}" unless $?.to_i == 0
      }
      psid = output.lines.to_a.last.to_i
      @logger.info "process id: #{psid}"
      {job_id: psid, raw_output: output.lines.map(&:chomp).to_a}
    end

    def status(job_id)
      cmd = "ps -p #{job_id}"
      output = `#{cmd}`
      status = $?.to_i == 0 ? :running : :finished
      { status: status, raw_output: output.lines.map(&:chomp).to_a }
    end

    def all_status
      cmd = "ps uxr | head -n 10"
      output = `#{cmd}`
      {raw_output: output.lines.map(&:chomp).to_a}
    end

    def delete(job_id)
      pgid = `ps -p #{job_id} -o "pgid"`.lines.to_a.last.to_i
      if $?.to_i == 0
        cmd = "kill -TERM -#{pgid}"
        system(cmd)
        raise "kill command failed: #{cmd}" unless $?.to_i == 0
        output = "process is killed"
      else
        output = "Process is not found"
      end
      {raw_output: output.lines.map(&:chomp).to_a}
    end
  end
end

require 'logger'

module Xsub

  class Base

    def template
      self.class::TEMPLATE
    end

    def parameter_definitions
      self.class::PARAMETERS
    end

    def submit(job_script, parameters, opt = {logger: Logger.new(STDERR), work_dir: '.', log_dir: '.'})
      @logger = opt[:logger]
      @work_dir = opt[:work_dir]
      @log_dir = opt[:log_dir]

      merged = default_parameters.merge( parameters )
      @logger.info "Parameters: #{merged.inspect}"
      verify_no_unknown_parameter(merged)
      verify_parameter_matches_format(merged)
      validate_parameters(merged)

      parent_script = render_template( merged.merge(job_file: File.expand_path(job_script)) )
      ps_path = parent_script_path(job_script)
      @logger.info "Parent script for #{job_script}: #{ps_path}"
      File.open( ps_path, 'w') {|f| f.write(parent_script); f.flush }
      @logger.info "Parent script has been written"
      output = submit_job(ps_path)
      output
    rescue => ex
      @logger.error(ex)
      raise ex
    end

    def status(job_id)
      raise "Override me"
    end

    def delete(job_id)
      raise "Override me"
    end

    private
    def default_parameters
      Hash[ parameter_definitions.map {|k,v| [k,v[:default]] } ]
    end

    def render_template(parameters)
      b = binding
      parameters.each do |name, value|
        b.eval("#{name} = #{value.inspect}")
      end
      ERB.new(self.class::TEMPLATE).result(b)
    end
      #Template.render( template, parameters)
    #end

    def validate_parameters(parameters)
      # You can override this method
    end

    def verify_no_unknown_parameter(parameters)
      extra = parameters.keys - default_parameters.keys
      unless extra.empty?
        raise "Unknown parameter exist : #{extra.inspect}"
      end
    end

    def verify_parameter_matches_format(parameters)
      parameter_definitions.each do |key,param_def|
        if param_def.has_key?(:format)
          unless parameters[key].to_s =~ Regexp.new(param_def[:format])
            raise "#{key}:#{parameters[key]} does not match #{param_def[:format]}"
          end
        end
      end
    end

    def parent_script_path( job_script )
      idx = 0
      parent_script = File.join(@work_dir, File.basename(job_script,'.sh') + "_xsub.sh")
      while File.exist?(parent_script)
        idx += 1
        parent_script = File.join(@work_dir, File.basename(job_script,'.sh') + "_xsub#{idx}.sh")
      end
      File.expand_path(parent_script)
    end
  end
end

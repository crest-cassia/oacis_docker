require 'optparse'
require 'json'
require 'logger'
require 'fileutils'

module Xsub

  module Submit

    LOG_ROTATE_SIZE = 7

    extend self

    def run(argv)
      scheduler = Xsub.load_scheduler
      parameters = {}
      logger = Logger.new(STDERR)
      work_dir = '.'
      log_dir = '.'

      OptionParser.new { |parser|
        parser.on('-t', '--show-template', 'show template') do |t|
          raise "scheduler type is not given" unless scheduler
          h = {parameters: scheduler.parameter_definitions, template: scheduler.template.lines.map(&:chomp) }
          $stdout.print JSON.pretty_generate(h)
          exit
        end

        parser.on('-p', '--parameters [PARAM]', 'parameters') do |param|
          parameters = JSON.load(param.sub(/^=/,'')) if param.size > 0
        end

        parser.on('-l', '--log [LOGDIR]', 'log directory name') do |log|
          if log.size > 0
            log_dir = log.sub(/^=/,'')
            FileUtils.mkdir_p(log_dir)
            log_file = File.join(log_dir, 'xsub.log')
            logger = Logger.new(log_file , LOG_ROTATE_SIZE)
          end
        end

        parser.on('-d', '--dir [WORKDIR]', 'work directory') do |dir|
          if dir.size > 0
            work_dir = dir.sub(/^=/, '')
            FileUtils.mkdir_p(work_dir)
          end
        end

      }.parse!(argv)

      raise "scheduler type is not given" unless scheduler
      raise "you should give a script to submit" unless argv.size == 1
      output = scheduler.submit(argv[0], parameters, logger: logger, work_dir: work_dir, log_dir: log_dir)
      $stdout.print JSON.pretty_generate(output)

    end
  end

  module Status

    extend self

    def run(argv)
      OptionParser.new.parse!(argv)

      scheduler = Xsub.load_scheduler
      raise "scheduler type is not given" unless scheduler
      job_id = argv[0]
      if job_id
        output = scheduler.status(job_id)
      else
        output = scheduler.all_status
      end
      $stdout.print JSON.pretty_generate(output)
    end
  end

  module Delete

    extend self

    def run(argv)
      OptionParser.new.parse!(argv)

      scheduler = Xsub.load_scheduler
      raise "scheduler type is not given" unless scheduler
      job_id = argv[0]
      if job_id
        output = scheduler.delete(job_id)
        $stdout.print JSON.pretty_generate(output)
      end
    end
  end
end

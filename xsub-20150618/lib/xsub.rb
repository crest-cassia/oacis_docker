require 'pp'
require 'json'
require 'fileutils'
require "xsub/version"
require "xsub/template"
require "xsub/base"
require "xsub/schedulers/none"
require "xsub/schedulers/torque"
require "xsub/schedulers/fx10"
require "xsub/schedulers/k"
require "xsub/schedulers/sr16000"

module Xsub

  SCHEDULER_TYPE = {
    none: Xsub::SchedulerNone,
    torque: Xsub::SchedulerTorque,
    fx10: Xsub::SchedulerFx10,
    k: Xsub::SchedulerK,
    sr16000: Xsub::SchedulerSR16000
  }

  def self.load_scheduler
    type = ENV['XSUB_TYPE']
    unless type
      $stderr.puts "Set environment variable 'XSUB_TYPE'"
      $stderr.puts "  You can set #{SCHEDULER_TYPE.keys.inspect}"
      raise " XSUB_TYPE is not set"
    end
    scheduler(type)
  end

  def self.scheduler(scheduler_type)
    key = scheduler_type.to_sym
    raise "unknown type: #{scheduler_type}" unless SCHEDULER_TYPE.has_key?(key)
    SCHEDULER_TYPE[scheduler_type.to_sym].new
  end
end

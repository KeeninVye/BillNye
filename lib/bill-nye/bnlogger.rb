require 'logger'

module BillNye
  class BNLogger
    def self.configure()
      #log_file = config["logging"]["file"] unless config["logging"]["file"].nil?
      #log_level = config["logging"]["level"] unless config["logging"]["level"].nil?
      #log_level = config["logging"]["rotation"] unless config["logging"]["rotation"].nil?

      log_file ||= "log.txt"#STDOUT
      log_level ||= 'info'
      log_rotation ||= 'daily'

      @logger = Logger.new(log_file, log_rotation)
      @logger.level = Logger.const_get(log_level.upcase.to_sym)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime}: [#{severity}] : #{msg}\n"
      end
    end

    def self.log
      return @logger
    end

  end
end

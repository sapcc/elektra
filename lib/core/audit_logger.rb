module Core
  class AuditLogger
    def initialize(logger=nil)
      @logger = logger
    end

    def debug(*args)
      log(:debug,*args)
    end

    def info(*args)
      log(:info,*args)
    end

    def warn(*args)
      log(:warn,*args)
    end

    def error(*args)
      log(:error,*args)
    end

    def fatal(*args)
      log(:fatal,*args)
    end

    private

    def value_to_string(value, include_object_name=false)
      string = ""
      if value.respond_to?(:name) or value.respond_to?(:id)
        string += "#{value.class.name.split('::').last} " if include_object_name
        string += value.name if value.respond_to?(:name)
        string += " (#{value.id})" if value.respond_to?(:id)
      else
        string += value.to_s
      end
      string += " "
    end

    def log(level, *args)
      message = args.collect do |arg|
        if arg.is_a?(Hash)
          m = ""
          arg.each{ |k,v| m += "#{k} #{value_to_string(v)} " }
          m
        elsif arg.is_a?(Array)
          arg.collect{ |v| value_to_string(v) }.join(' ')
        else
          value_to_string(arg,true)
        end
      end

      @logger.tagged("AUDIT LOG"){@logger.send(level,message.join(' '))}
    end
  end

  module AuditLog
    def audit_logger
      return @audit_logger if @audit_logger
  
      current_logger = if self.respond_to?(:logger) and self.logger
        self.logger  
      elsif Rails.respond_to?(:logger) and Rails.logger
        Rails.logger
      else
        ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
      end

      @audit_logger = Core::AuditLogger.new(ActiveSupport::TaggedLogging.new(current_logger))
    end
  end
end

::ActionController::Base.send(:include,Core::AuditLog)
::Core::ServiceLayer::Service.send(:include, Core::AuditLog)

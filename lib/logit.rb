module Logit
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    DEFAULT_OPTS = {:write_mode => 'a'}

    # === Options
    # * +:write_mode+ - mode used when opening the log file.  You'll ususually just want 'a' for append or 'w' for overwrite.  Defaults to 'a'.
    # * +:shift_age+ - Number of old logs to keep or frequency of rotation.
    # * +:shift_size+ - Maximum logfile size that only applies when <tt>:shift_age</tt> is a number.
    # * +:progname+ - Logging program name.  The <tt>:progname</tt> value is used in the default logging format if defined.
    #
    # === Examples
    # 
    #  class Publisher
    #    include Logit
    #
    #    logs_to "/tmp/publisher.log"
    #
    #    def do_it
    #      logger.info("doing something")
    #    end
    #  end
    # 
    #
    #  class Publisher2
    #    include Logit
    #
    #    logs_to :publisher, :progname => "Publisher #{Process.pid}"
    #                        :shift_age => 'daily'
    #    def do_it
    #      logger.info("doing something")
    #    end
    #  end
    #  
    def logs_to(name, opts={})
      opts = DEFAULT_OPTS.merge(opts)
      self.send :define_method, :logger do
        unless @logger
          path = "#{name}.log"
          if (Rails)
            path = File.join(RAILS_ROOT, 'log', "#{name}_#{Rails.env}.log")
          end
          @logger =  Logit::Logger.new(path, opts)
          if opts[:progname]
            @logger.progname = opts[:progname]
          end
        end
        @logger
      end
    end
  end



  # The actual logger.
  #
  # Example:
  #
  #   c = Logit::Logger.new('custom')
  #
  # such that the resulting log, for example, is
  #
  #   #{RAILS_ROOT}/log/custom_development.log
  #
  # when running under Rails.
  #
  # You can flush the log by calling logger.flush().
  #
  class Logger < Logger
  
    def initialize(log_path, opts = {:write_mode => 'a'})
      @f = File.open(log_path, 'a')
      super @f
    end
  
    def format_message(severity, timestamp, progname, msg)
  
      name = (progname) ? " [#{progname}]" : ""
  
      "#{timestamp.strftime('%d-%m-%Y %H:%M:%S')} #{severity.ljust(6)}#{name}: #{msg}\n"
    end
  
    def flush()
      @f.flush()
    end
  end

end

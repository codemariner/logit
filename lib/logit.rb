module Logit

  DEFAULT_OPTS = {:write_mode => 'a', :flush_mode => :default, :log_method => :logger, :stdout => false}

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    unless Object.const_defined?(:Logger)
      require 'logger'
    end

    # === Options
    # * +:write_mode+ - mode used when opening the log file.  You'll ususually just want 'a' for append or 'w' for overwrite.  Defaults to 'a'.
    # * +:shift_age+ - Number of old logs to keep or frequency of rotation.
    # * +:shift_size+ - Maximum logfile size that only applies when <tt>:shift_age</tt> is a number.
    # * +:progname+ - Logging program name.  The <tt>:progname</tt> value is used in the default logging format if defined.
    # * +:flush_mode+ - One of <tt>:immediate</tt> or <tt>:default</tt>.  <tt>:immediate</tt> will cause a write to the log file for each message logged.  The default behavior is to use default file buffering.
    # * +:stdout+ - If set to <tt>true</tt>, this will cause logs to be printed to stdout <b>in addition to</b> the log file.
    # * +:log_method+ - The name of the instance method to define to access the logger instance.  Defaults to <tt>:logger</tt>.
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
    #  class Publisher3
    #    include Logit
    #
    #    logs_to :publisher, :log_method => :pub_log
    #
    #    def do_it
    #      pub_log.info("doing something")
    #    end
    #  end
    #  
    def logs_to(name, opts={})
      opts = DEFAULT_OPTS.merge(opts)
      path = logit_log_name(name, opts)

      self.class.send :define_method, :logit_logger do
        unless @logger
          @logger =  Logit::Logger.new(path, opts)
          if opts[:progname]
            @logger.progname = opts[:progname]
          end
        end
        @logger
      end

      self.send :define_method, opts[:log_method] do
        self.class.send :logit_logger
      end
    end


    # Tries to figure out what the fully qualified path name
    # of the log file should be.
    #
    def logit_log_name(name, opts)
      path = name.to_s.strip

      #  if they are giving a path like '/var/log/foo.log'
      #  then we shouldn't presume to stick it in the Rails log dir
      unless (path =~ /\/+/) 
        if (logit_in_rails?)
          # take off any trailing .log so we can attach the environment
          # name
          path = logit_strip_dot_log(path)
          path = File.join(RAILS_ROOT, 'log', "#{name}_#{Rails.env}.log")
        end
      end
      # see if we need to append .log
      # is this a bit presumptuous?
      unless (path =~ /\.log$/)
        path << ".log"
      end
      path
    end

    def logit_strip_dot_log(name)
      if (name =~ /\.log$/)
        name.slice(0, name =~ /\.log$/) 
      else
        name
      end
    end
    def logit_in_rails?
      begin
        Module.const_get(:Rails)
        return true
      rescue NameError
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
  class Logger < Logger
  
    def initialize(log_path, opts = DEFAULT_OPTS)
      @opts = DEFAULT_OPTS.merge(opts)
      f = File.open(log_path, @opts[:write_mode])
      if (opts[:flush_mode] == :immediate)
        f.sync = true
      end
      super f
    end
  
    def format_message(severity, timestamp, progname, msg)
      name = (progname) ? " [#{progname}]" : ""
  
      message = "#{timestamp.strftime('%m-%d-%Y %H:%M:%S')} #{severity.ljust(6)}#{name}: #{msg}\n"
      puts message if @opts[:stdout]
      message
    end

    def add(severity, message = nil, progname = nil, &block)
      super(severity, message, progname, &block)
    end

    # flushes any buffered content to the log
    def flush
      # get a handle to the actual file and then synchronize on the mutex
      # that LogDevice is using (so we don't have the file closed or
      # swapped out from under us)
      if @logdev 
        mutex = @logdev.instance_variable_get('@mutex')
        if (mutex)
          mutex.synchronize do 
            dev = @logdev.dev
            if (dev and !dev.closed?)
              dev.flush()
            end
          end
        end
      end
      true
    end
  end

end

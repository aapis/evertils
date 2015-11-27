module Evertils
  module Model
    class Data
      attr_accessor :identifier, :branch, :browser, :files_with_errors

      def initialize()
        @d = Hash.new([])

        # setup defaults
        defaults = {
          :issues => {:errors => 0, :warnings => 0},
          :status => {:success => 0, :error => 0, :total => 0, :errors_per_file => 0},
          :success_rate => {:int => 0, :str => "0%"},
          :log => '',
          :below_acceptable_limit => false
        }

        @branch = Command::Exec.git_current_branch
        @files_with_errors = []

        @d.merge! defaults
      end

      def unset(key)
        @d.delete(key.to_sym)
      end

      def instance_var(key, val = nil)
        self.class.__send__(:attr_accessor, key)
        instance_variable_set("@#{key}", val)
      end

      def serialize
        @d.to_json
      end

      def status
        get(:status)
      end

      def success_rate
        get(:success_rate)
      end

      def increment_issues(key, val)
        @d[:issues][key.to_sym] += val
      end

      def increment_status(key, val)
        @d[:status][key.to_sym] += val
      end

      def issues
        get(:issues)
      end

      def issues=(val)
        set(:issues, val)
      end

      def log
        get(:log, Evertils::DEFAULT_LOG)
      end

      def add_to_error_list(file)
        @files_with_errors << file
      end

      def identifier=(val)
        @identifier = val

        # create the log file now
        @d[:log] = Log.new(@branch, Time.now, @identifier)
      end

      def below_acceptable_limit?
        get(:below_acceptable_limit) == true
      end

      def below_acceptable_limit=(val)
        set(:below_acceptable_limit, val)
      end

      def bind!(seed_data)
        @d = seed_data
      end

      def get(key, default = @d.default)
        @d[key] || default
      end

      def set(key, val = nil)
        @d[key] = val
      end
    end
  end
end

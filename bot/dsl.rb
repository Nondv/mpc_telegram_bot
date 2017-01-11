class Bot
  module DSL
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      def def_command(name, &block)
        self.commands = commands.merge(name => block).freeze
      end

      def def_command_processing(name, &block)
        self.command_processors = command_processors.merge(name => block).freeze
      end

      def command_block(command_name)
        commands[command_name]
      end

      def command_processor_block(command_name)
        command_processors[command_name]
      end

      private

      attr_writer :commands
      attr_writer :command_processors

      def commands
        @commands ||= {}.freeze
      end

      def command_processors
        @command_processors ||= {}.freeze
      end
    end
  end
end

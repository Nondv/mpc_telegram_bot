class Bot
  module DSL
    def self.included(klass)
      klass.extend ClassMethods
      klass.include InstanceMethods
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

    module InstanceMethods
      private

      def respond(msg, params = {})
        telegram_bot.api.send_message(params.merge(chat_id: msg.chat.id))
      end

      def execute_command(name, message)
        block = command_block(name)
        raise "#{name} not defined" unless block

        instance_exec(message, &block)
      end

      def continue_command(message)
        command_name = command_in_progress(message.chat.id)
        raise 'no command in progress' unless command_name

        block = command_processor_block(command_name)
        raise "#{command_name} processor not defined" unless block

        instance_exec(message, &block)
      end

      def command_in_progress(chat_id)
        processing_command_hash[chat_id]
      end

      def start_command(message)
        processing_command_hash[message.chat.id] = message.text
      end

      def stop_command(message)
        processing_command_hash.delete(message.chat.id)
      end

      # don't use it directly!
      def processing_command_hash
        @processing_command_hash ||= {}
      end

      def command_block(name)
        self.class.command_block(name)
      end

      alias command_defined? command_block

      def command_processor_block(name)
        self.class.command_processor_block(name)
      end
    end
  end
end

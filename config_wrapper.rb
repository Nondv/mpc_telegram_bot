require 'yaml'

module Config
  @data = YAML.load(File.read('config.yml'))

  module_function

  def api_port
    @data['api'] && @data['api']['port'] || 9090
  end

  def api_pid_file
    result = @data['api'] && @data['api']['pid_file'] || 'api.pid'
    File.absolute_path(result)
  end

  def bot_pid_file
    result = @data['bot'] && @data['bot']['pid_file'] || 'bot.pid'
    File.absolute_path(result)
  end

  def bot_token
    @data['bot'] && @data['bot']['token']
  end

  def bot_log_file
    result = @data['bot'] && @data['bot']['log_file'] || 'bot.log'
    File.absolute_path(result)
  end
end

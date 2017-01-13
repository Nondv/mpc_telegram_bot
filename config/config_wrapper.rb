require 'yaml'

module Config
  @path_to_config = File.expand_path('../config.yml', __FILE__)
  @data = YAML.load(File.read(@path_to_config))

  module_function

  def api_port
    @data['api'] && @data['api']['port'] || 9090
  end

  def api_pid_file
    default = File.expand_path('../../tmp/pids/api.pid', __FILE__)
    result = @data['api'] && @data['api']['pid_file'] || default
    File.absolute_path(result)
  end

  def bot_pid_file
    default = File.expand_path('../../tmp/pids/bot.pid', __FILE__)
    result = @data['bot'] && @data['bot']['pid_file'] || default
    File.absolute_path(result)
  end

  def bot_token
    @data['bot'] && @data['bot']['token']
  end

  def bot_log_file
    default = File.expand_path('../../log/bot.log', __FILE__)
    result = @data['bot'] && @data['bot']['log_file'] || default
    File.absolute_path(result)
  end
end

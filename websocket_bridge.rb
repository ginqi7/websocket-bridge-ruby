require 'faye/websocket'
require 'json'

class WebsocketBridge
  def initialize(app_name, server_port)
    @app_name = app_name
    @server_port = server_port
    @ws = Faye::WebSocket::Client.new("ws://127.0.0.1:#{@server_port}")
    @ws.on :open do |_event|
      on_open
    end

    @ws.on :message do |event|
      data = JSON.parse(event.data)
      on_message(data[1])
    end

    @ws.on :close do |event|
      puts "WebSocket Client [#{@app_name}] close, code: [#{event.code}], reason: [#{event.reason}]"
    end
  end

  def on_open
    puts "WebSocket Client [#{@app_name}] connected, the server port is #{@server_port}"
    data = {
      'type' => 'client-app-name',
      'content' => @app_name
    }
    json = JSON.generate(data)
    @ws.send(json)
  end

  def on_message(_data)
    puts 'Please Reimplement yourself.'
  end

  def eval_in_emacs(code)
    data = {
      'type' => 'eval-code',
      'content' => code
    }
    json = JSON.generate(data)
    puts code
    @ws.send(json)
  end

  def run_in_emacs(func, *args)
    args_str = args.map { |arg| "\"#{arg}\"" }.join(' ')
    eval_in_emacs("(#{func} #{args_str})")
  end
end

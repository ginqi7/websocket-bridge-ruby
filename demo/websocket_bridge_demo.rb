require 'eventmachine'
require_relative '../lib/websocket_bridge'

class WebsocketBridgeDemo < WebsocketBridge::Base
  def on_message(data)
    puts data
    eval_in_emacs('(message "Hello")')
    run_in_emacs('message', 'World')
  end
end
EM.run do
  WebsocketBridgeDemo.new(ARGV[0], ARGV[1])
end

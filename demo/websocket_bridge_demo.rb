require 'eventmachine'
require_relative '../lib/websocket_bridge'

class WebsocketBridgeDemo < WebsocketBridge::Base
  def on_message(_data)
    run_in_emacs('ruby-demo-print', 'World')
    run_in_emacs('ruby-demo-print', 1)
    run_in_emacs('ruby-demo-print', 2.0)
    run_in_emacs('ruby-demo-print', [1, 2.0, 'word'])
    data = {}
    data[:name] = 'hello'
    data[:value] = [1, 2, 3, '995']
    run_in_emacs('ruby-demo-print', data)
    run_in_emacs('ruby-demo-print', 1, 2, 3.0, 'Hlle', data)
  end
end
EM.run do
  WebsocketBridgeDemo.new(ARGV[0], ARGV[1])
end

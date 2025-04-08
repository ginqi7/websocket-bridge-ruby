# frozen_string_literal: true

require_relative 'websocket_bridge/version'
require 'faye/websocket'
require 'json'

module WebsocketBridge
  class Error < StandardError; end

  class Base
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

    def value_format(value)
      case value
      when String
        "\"#{value}\""
      when Integer
        value.to_s
      when Float
        value.to_s
      when Array
        args = value.map { |one| value_format(one) }.join(' ')
        "(list #{args})"
      when Hash
        args = value.map { |key, v| ":#{key} #{value_format(v)}" }.join(' ')
        "(list #{args})"
      when Symbol
        ''
      when TrueClass
        't'
      when FalseClass
        'nil'
      else
        puts "The value is of an unknown type: #{value.class}."
      end
    end

    def run_in_emacs(func, *args)
      args_str = args.map { |arg| value_format(arg) }.join(' ')
      eval_in_emacs("(#{func} #{args_str})")
    end
  end
end

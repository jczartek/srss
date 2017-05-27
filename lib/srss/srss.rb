module SRSS
  module Signalable

    class NoBlockError < Exception
    end

    def connect(name, &blk)
      unless block_given?
        raise NoBlockError, "When connecting signal must given a block!"
      end

      @_signal_connections ||= []
      @_next_connection_id ||= 1

      id = @_next_connection_id
      @_next_connection_id = @_next_connection_id + 1

      @_signal_connections.push({
        :id           => id,
        :name         => name,
        :callback     => blk,
        :blocked => false
      })

      id
    end

    def disconnect(id)
      raise ArgumentError, "No signal handler #{id} found" unless @_signal_connections

      @_signal_connections.reject! {|handler|; handler[:id] == id; }
    end

    def disconnect_all()
      @_signal_connections = []
      @_next_connection_id = 1
    end

    def block(id)
      handler = @_signal_connections.detect { |handler| handler[:id] == id }

      unless handler.nil?
        handler[:blocked] = true
      end
    end

    def unblock(id)
      handler = @_signal_connections.detect { |handler| handler[:id] == id }

      unless handler.nil?
        handler[:blocked] = false
      end
    end

    def connected?(id)
      @_signal_connections.any? { |handler| handler[:id] == id }
    end

    def blocked?(id)
      @_signal_connections.any? { |handle| handler[:id] == id and handler[:blocked] == true }
    end

    def emit(name, *args)
      return unless @_signal_connections

      handlers = @_signal_connections.select {|handler| name == handler[:name]}

      args_handler = [self]
      args_handler.concat(args) if args.any?

      handlers.each do |handler;ret|
        unless handler[:blocked]
          begin
          ret = handler[:callback].call(*args_handler)
          break if ret == true
          rescue => e
            puts e.message
          end
        end
      end
    end
  end
end

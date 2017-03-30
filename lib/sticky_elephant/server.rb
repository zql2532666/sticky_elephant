module StickyElephant
  class Server
    def initialize(configuration)
      @host = configuration.host
      @port = configuration.port

      @logger = ElephantLogger.new(configuration)
      @logger.level = configuration.log_level
      @logger.info(log_name) { "Launching" }
    end

    def listen
      @server = TCPServer.open(host, port)
      loop do
        begin
          Thread.start(server.accept) do |socket|
            Connection.new(socket, logger: logger).process
          end
        rescue Interrupt
          logger.info(log_name) { "Caught ctrl-c, shutting down" }
          Thread.list.each {|t| t.kill unless t == Thread.current }
          logger.close
          exit(0)
        end
      end
    end

    private

    attr_reader :host, :port, :server, :logger

    def log_name
      "SE server"
    end
  end
end

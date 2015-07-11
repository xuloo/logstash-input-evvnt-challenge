# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname

# Generate a repeating message.
#
# This plugin is intented only as an example.

class LogStash::Inputs::Evvnt < LogStash::Inputs::Base
  config_name "evvnt"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain" 

  # Evvnt feed host
  config :host, :validate => :string, :required => true

  # Evvnt feed path
  config :path, validate => :string, :required => true

  #
  # The default, `1`, means send a message every second.
  config :interval, :validate => :number, :default => 60

  public
  def register
    @logger.info("Registering Evvnt Input", :url => @url, :interval => @interval)
  end # def register

  def run(queue)
     start = Time.now
     @logger.info? && @logger.info("Polling Evvnt", :url => @url)

    connection = Faraday.new @host do |conn|
      conn.response :json, :content_type => /\bjson$/

      conn.adapter Faraday.default_adapter
    end

    response = connection.get(@path)

    response.body.each { |event|
      decorate(event)
      queue << event
    } 

    duration = Time.now - start
    @logger.info? && @logger.info("Command completed", :command => @command, :duration => duration)

    # Sleep for the remainder of the interval, or 0 if the duration ran
    # longer than the interval.
    sleeptime = [0, @interval - duration].max
    if sleeptime == 0
      @logger.warn("Execution ran longer than the interval. Skipping sleep.", :command => @command, :duration => duration, :interval => @interval)
    else
      sleep(sleeptime)
    end
  end # def run

end # class LogStash::Inputs::Example

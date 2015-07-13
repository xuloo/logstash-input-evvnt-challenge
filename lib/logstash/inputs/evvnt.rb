# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "faraday"
require 'faraday_middleware'

#
# Hits the challenge endpoint every {interval} seconds and sends the data upstream
#

class LogStash::Inputs::Evvnt < LogStash::Inputs::Base
  config_name "evvnt"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain" 

  # SSL cert directory
  config :capath, :validate => :string, :default => "/usr/lib/ssl/certs"

  # Evvnt feed host
  config :host, :validate => :string, :required => true

  # Evvnt feed path
  config :path, :validate => :string, :required => true
  
  # Basic Auth 'user' 
  config :user, :validate => :string, :required => true
  
  # Basic Auth 'password'
  config :pass, :validate => :string, :required => true

  # The default, `60`, means send a message every minute.
  config :interval, :validate => :number, :default => 60
  
  public
  def register
    @logger.info("Registering Evvnt Input", :host => @host, :path => @path,  :interval => @interval)
  end # def register

  def run(queue)

    # start the interval job
    Stud.interval(@interval) do
      connection = Faraday.new(:url => @host, :ssl => {
         :ca_path => @capath
        }) do |conn|

        # middleware used to set the response content-type to json
        conn.response :json, :content_type => /\bjson$/
    
        conn.adapter Faraday.default_adapter
      end

      # set the Authentication header
      connection.basic_auth(@user, @pass)

      # make the request
      response = connection.get(@path)
  
      # for each entry in the response enqueue a new event
      response.body.each { |ev|
        event = LogStash::Event.new("event" => ev)
        decorate(event)
        queue << event
      }
    end # loop
  end # def run

end # class LogStash::Inputs::Example

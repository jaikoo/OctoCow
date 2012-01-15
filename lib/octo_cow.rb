require 'logger'
require 'hashie'
require 'faraday'
require 'faraday_middleware'
require 'ostruct'
require 'multi_json'

module OctoCow

	GITHUB_API_VERSION = 'v3'

	@@logging = false
	@@log 		= Logger.new($STDOUT)

	def self.enable_logging
		@@logging = true
		@@log.level = Logger::DEBUG
	end

	def self.disable_logging
		@@logging = false
		@@log.level = Logger::ERROR
	end

	class Session	
		attr_accessor :token
    attr_accessor :username


		def initialize(username, auth_token = nil)
      @token = auth_token
      @username = username
      @conn = OctoCow::Connection.new(auth_token)
    end

    def organisations(&block)
      raise ArgumentError, "Needs a block to be passed" unless block_given?
      path = @token ? '/user/orgs' : "/users/#{@username}/orgs"
      call(path).each do |org|
        yield Organisation.new(org.merge(session: self))
      end
    end

    def organisation(id)
      path = "/org/#{id}"
      # call(path).map {|org| Organisation.load(self, org)}
    end

    def call(path)
      @conn.call(path)
    end


  end



  class Organisation < OpenStruct

    def teams(&block)
      raise ArgumentError, "Needs a block to be passed" unless block_given?
      path = "/orgs/#{login}/teams"
      session.call(path).each do |team| 
        yield Team.new(team.merge(session: session))
      end
    end

  end


  class Team < OpenStruct

    def members
      
    end

  end



  class Connection
    attr_reader :connection

    def initialize(auth_token)
      auth_opts = auth_token ? {Authorization: "token #{auth_token}"} : {}
      @connection = Faraday::Connection.new(
                  url: 'https://api.github.com',
                  headers: {:accept => 'application/json',
                            user_agent: 'OctoCow'
                            }.merge(auth_opts)) do |builder|
                builder.use Faraday::Adapter::NetHttp
                builder.use Faraday::Response::Mashify
                builder.use Faraday::Response::ParseJson
              end
      @connection
    end

    def call(path)
      @connection.get(path).body
    end
  end


end
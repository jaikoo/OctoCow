require 'logger'
require 'hashie'
require 'faraday'
require 'faraday_middleware'

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

    def organisations
      path = @token ? '/user/orgs' : "/users/#{@username}/orgs"
      puts path
      call(path)
    end

    def organisation(id)
      path = "/org/#{id}"
      call(path).map {|org| Organisation.new(self, org)}
    end

    def call(path)
      @conn.call(path)
    end


  end


  class Organisation < Hashie::Mash; 
    attr_reader :session
    def initialize(session, opts)
      @session = session
      super(opts)
    end

    def teams
      path = "/orgs/#{login}/teams"
      @session.call(path).map {|t| Team.new(session, t)}
    end

  end

  class Team < Hashie::Mash
    attr_reader :session
    
    def initialize(session, opts)
      @session = session
      super(opts)
    end

    def members
      
    end

  end



  class Connection
    attr_reader :connection

    def initialize(auth_token)
      auth_opts = auth_token ? {Authorization: "token #{auth_token}"} : {}
      puts auth_opts
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
      b = @connection.get(path).body
      puts b
      b
    end
  end


end
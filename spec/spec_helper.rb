require File.dirname(__FILE__) + '/../lib/octo_cow'
require 'rspec'
require 'yaml'

module Settings
	def self.auth_key
	  @key ||= YAML::load_file(File.dirname(__FILE__) + '/test_config.yml')['key']  
	end  

	def self.username
		@username ||= YAML::load_file(File.dirname(__FILE__) + '/test_config.yml')['username']  
	end
end

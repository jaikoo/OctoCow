require File.dirname(__FILE__) + '/spec_helper'

describe OctoCow do 

	describe OctoCow::Session do

    before do
      @authed_session = OctoCow::Session.new(Settings::username, Settings::auth_key)
      @session =  OctoCow::Session.new(Settings::username)
    end

    describe '#organisations' do

      it 'should return a list of organisations the user belongs to' do
        @authed_session.organisations.each {|o| o.instance_of? OctoCow::Organisation}  
      end



    end

  end



end
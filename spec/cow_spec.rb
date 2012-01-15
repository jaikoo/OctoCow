require File.dirname(__FILE__) + '/spec_helper'

describe OctoCow do 

	describe OctoCow::Session do

    before do
      @authed_session = OctoCow::Session.new(Settings::username, Settings::auth_key)
      @session =  OctoCow::Session.new(Settings::username)
    end

    describe '#organisations' do

      it 'should return a list of organisations the user belongs to' do
        @authed_session.organisations {|o| o.should be_instance_of OctoCow::Organisation}  
        @authed_session.organisations {|o| o.login.should_not be_nil}        
      end

      it 'should contain a session context' do
        @authed_session.organisations {|o| o.session.should_not be_nil}  
      end

      describe '#teams' do

        it 'should be possible to get a list of teams of an organisation' do
          @authed_session.organisations do |org|
            org.teams do |team|
              team.should be_instance_of OctoCow::Team
              team.name.should_not be_nil              
            end
          end
        end

        describe '#members' do
          it 'should be possible to see members of a team' do
            @authed_session.organisations do |org|
              org.teams do |team|
                team.members {|member| member.should be_instance_of OctoCow::User}
              end
            end            
          end  

        end

    end


    end

  end



end
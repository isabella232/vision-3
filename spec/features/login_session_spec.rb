require "spec_helper"

RSpec.describe "Login session timeout testing", :type=>:request do
	it "User login session should be in two weeks" do
		user = FactoryGirl.create(:user)
		login_as(user)
		login_time = Time.current

		#forward time to 14 days later
		Timecop.freeze(Time.current + 13.days) do
			#login_time is last time user login
			expect(user.timedout?(login_time)).to eq(false)
		end

		#forward time to 14 days later
		Timecop.freeze(Time.current + 14.days) do
			#login_time is last time user login
			expect(user.timedout?(login_time)).to eq(true)
		end
	end
end
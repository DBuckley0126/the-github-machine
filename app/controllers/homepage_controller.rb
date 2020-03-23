# require_relative '../helpers/homepage_helper.rb'
include HomepageHelper

class HomepageController < ApplicationController
  def index
  end

  def show
    if strong_params[:username].empty?
      @error_message = "Please enter a GitHub Username"
      render 'homepage/index'
      return
    end

    result = HomepageHelper.get_user_data(strong_params[:username])

    if result[:error]
      @error_message = result[:message]
      render 'homepage/index'
      return
    end

    
    @language_data = HomepageHelper.process_data(result[:data][:languages])
    @username = result[:data][:username]
  end

end

def strong_params
  params.permit(:username)
end
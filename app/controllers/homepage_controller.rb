# require_relative '../helpers/homepage_helper.rb'
include HomepageHelper

class HomepageController < ApplicationController
  def index
  end

  def show
    result = HomepageHelper.get_user_data(strong_params)
    
    @error = result.error
    @message = result.message
    @sorted_language_tally = result.data
  end

end

def strong_params
  params.require(:username)
end
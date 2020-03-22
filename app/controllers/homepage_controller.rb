class HomepageController < ApplicationController
  def index
  end

  def show
    Octokit.configure do |c|
      c.auto_paginate = true
      c.connection_options = {
        request: {
          open_timeout: 5,
          timeout: 5
        }
      }
    end

    client = Octokit::Client.new(:access_token => "2d8e510ebe6bbf8603cfd3de9b05ff8b733683cf", per_page: 100)

    # Fetch user
    begin
      user = client.user strong_params
    rescue StandardError => e
      if e.class == Octokit::TooManyRequests
        puts "Request limit reached"
      else
        puts "No user found"
      end
    end

    begin
      repo_data_array = client.get(user.repos_url + "?per_page=100")

      last_res_count = repo_data_array.count

      while last_res_count == 100 do
        if client.last_response.rels[:next].href
          next_res = client.get(client.last_response.rels[:next].href)
          repo_data_array.concat(next_res)
          last_res_count = next_res.count
        end
      end
    rescue StandardError => e
      puts "No repos found"
    end

    user_repo_languages = repo_data_array.map do |repo|
      if repo.language == nil
        "Unknown"
      else
        repo.language
      end
    end

    total_hash = user_repo_languages.tally
    @sorted_languages = total_hash.sort_by(&:last).reverse
    
  end

end

def strong_params
  params.require(:username)
end
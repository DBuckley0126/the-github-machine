module HomepageHelper
  def get_user_data(username)
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
      user = client.user username
    rescue StandardError
      e.class == Octokit::TooManyRequests ? { error: true, message: 'Request limit reached', data: false } : { error: true, message: 'No user found', data: false }
    end

    if !user 
      return { error: true, message: 'No user found' }
    end

    begin
      repo_data_array = client.get(user.repos_url + '?per_page=100')
      last_res_count = repo_data_array.count

      while last_res_count == 100 do
        if client.last_response.rels[:next].href
          next_res = client.get(client.last_response.rels[:next].href)
          repo_data_array.concat(next_res)
          last_res_count = next_res.count
        end
      end
    rescue StandardError
      return { error: true, message: 'No repos found', data: false }
    end

    user_repo_languages = repo_data_array.map do |repo|
      if repo.language.nil?
        'Unknown'
      else
        repo.language
      end
    end

    language_tally = user_repo_languages.tally
    sorted_language_tally = language_tally.sort_by(&:last).reverse
    { error: false, message: '', data: sorted_language_tally }
  end

  def hello
    puts "hello"
  end

end

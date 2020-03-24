module HomepageHelper
  def get_user_data(username)
    Octokit.configure do |c|
      c.auto_paginate = true
      c.connection_options = { request: { open_timeout: 5, timeout: 5 } }
    end

    client =
      Octokit::Client.new(
        access_token: Rails.application.credentials.GITHUB_ACCESS_TOKEN,
        per_page: 100
      )

    begin
      user_results = client.root.rels[:user_search].get(query: { q: username })

      raise ArgumentError unless user_results.data.total_count > 0

      user = user_results.data.items[0]
    rescue StandardError => e
      if e.class == Octokit::TooManyRequests
        return { error: true, message: 'Request limit reached', data: false }
      else
        return { error: true, message: 'No user found', data: false }
      end
    end

    begin
      repo_data_array = client.get(user.repos_url + '?per_page=100')
      last_res_count = repo_data_array.count

      while last_res_count == 100
        if client.last_response.rels[:next].href
          next_res = client.get(client.last_response.rels[:next].href)
          repo_data_array.concat(next_res)
          last_res_count = next_res.count
        end
      end
    rescue StandardError => e
      return { error: true, message: 'No repos found', data: false }
    end

    user_repo_languages =
      repo_data_array.map do |repo|
        repo.language.nil? ? 'Unknown' : repo.language
      end

    language_tally = user_repo_languages.tally
    sorted_language_tally = language_tally.sort_by(&:last).reverse
    {
      error: false,
      message: '',
      data: { languages: sorted_language_tally, username: user.login }
    }
  end

  def process_data(languages)
    output_array = []
    total_count_of_repos = languages.sum { |language| language[1] }
    compressed_division = 100.0 / total_count_of_repos

    current_sum_of_percentages = 0
    languages.each do |language|
      percentage = compressed_division * language[1]
      color = self.retrieve_color(language[0])
      output_array.push(
        {
          language_name: language[0],
          color: color,
          language_tally: language[1],
          pie_data:
            "--offset: #{current_sum_of_percentages}; --value: #{
              percentage
            }; --bg: #{color}; --over50: #{percentage > 50 ? 1 : 0}"
        }
      )
      current_sum_of_percentages += percentage
    end
    output_array
  end

  def retrieve_color(language)
    file = File.read('./lib/assets/github_colors.json')
    color_hash = JSON.parse(file)
    found_color = color_hash[language]
    if found_color
      self.verify_color(found_color['color'], color_hash)
    else
      random_picked_color = color_hash.to_a.sample(1).to_h
      self.verify_color(
        random_picked_color[random_picked_color.keys[0]]['color'],
        color_hash
      )
    end
  end

  def verify_color(color, color_hash)
    if color
      return color
    else
      random_picked_color = color_hash.to_a.sample(1).to_h
      self.verify_color(
        random_picked_color[random_picked_color.keys[0]]['color'],
        color_hash
      )
    end
  end

  def label_color_generator(color)
    "background-color:#{color};"
  end
end

require 'httparty'

class Twitch
  def initialize(options = {})
    @client_id = options[:client_id] || nil
    @secret_key = options[:secret_key] || nil
    @redirect_uri = options[:redirect_uri] || nil
    @scope = options[:scope] || nil
    @access_token = options[:access_token] || nil

    @base_url = 'https://api.twitch.tv/kraken'
  end

  public

  def get_link
    scope = @scope.join('+')
    "https://api.twitch.tv/kraken/oauth2/authorize?response_type=code&client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&scope=#{scope}"
  end

  def auth(code)
    path = '/oauth2/token'
    url = @base_url + path
    post(url,
         client_id: @client_id,
         client_secret: @secret_key,
         grant_type: 'authorization_code',
         redirect_uri: @redirect_uri,
         code: code
    )
  end

  # User

  def get_user(user)
    path = '/users/'
    url = @base_url + path + user
    get(url)
  end

  def get_your_user
    return false unless @access_token
    path = "/user?oauth_token=#{@access_token}"
    url = @base_url + path
    get(url)
  end

  # Teams

  def get_teams
    path = '/teams/'
    url = @base_url + path
    get(url)
  end


  def get_team(team_id)
    path = '/teams/'
    url = @base_url + path + team_id
    get(url)
  end

  # Channel

  def get_channel(channel)
    path = '/channels/'
    url = @base_url + path + channel
    get(url)
  end

  def get_your_channel
    return false unless @access_token
    path = "/channel?oauth_token=#{@access_token}"
    url = @base_url + path
    get(url)
  end

  def edit_channel(status, game)
    return false unless @access_token
    path = "/channels/dustinlakin/?oauth_token=#{@access_token}"
    url = @base_url + path
    data = {
      :channel => {
        :game => game,
        :status => status
      }
    }
    put(url, data)
  end

  def follow_channel(username, channel)
    return false unless @access_token
    path = "/users/#{username}/follows/channels/#{channel}?oauth_token=#{@access_token}"
    url = @base_url + path
    put(url)
  end

  def run_commercial(channel, length = 30)
    return false unless @access_token
    path = "/channels/#{channel}/commercial?oauth_token=#{@access_token}"
    url = @base_url + path
    post(url, {
              :length => length
            })
  end

  # Streams

  def get_stream(stream_name)
    path = "/streams/#{stream_name}"
    url = @base_url + path
    get(url)
  end

  def get_streams(options = {})
    query = build_query_string(options)
    path = '/streams'
    url = @base_url + path + query
    get(url)
  end

  def get_featured_streams(options = {})
    query = build_query_string(options)
    path = '/streams/featured'
    url = @base_url + path + query
    get(url)
  end

  def get_summarized_streams(options = {})
    query = build_query_string(options)
    path = '/streams/summary'
    url = @base_url + path + query
    get(url)
  end

  def get_your_followed_streams
    path = "/streams/followed?oauth_token=#{@access_token}"
    url = @base_url + path
    get(url)
  end

  #Games

  def get_top_games(options = {})
    query = build_query_string(options)
    path = '/games/top'
    url = @base_url + path + query
    get(url)
  end

  #Search

  def search_streams(options = {})
    query = build_query_string(options)
    path = '/search/streams'
    url = @base_url + path + query
    get(url)
  end

  def search_games(options = {})
    query = build_query_string(options)
    path = '/search/games'
    url = @base_url + path + query
    get(url)
  end

  # Videos

  def get_channel_videos(channel, options = {})
    query = build_query_string(options)
    path = "/channels/#{channel}/videos"
    url = @base_url + path + query
    get(url)
  end

  def get_video(video_id)
    path = "/videos/#{video_id}/"
    url = @base_url + path
    get(url)
  end

  def is_subscribed(username, channel, options = {})
    query = build_query_string(options)
    path = "/users/#{username}/subscriptions/#{channel}?oauth_token=#{@access_token}"
    url = @base_url + path + query
    get(url)
  end

  private
  def build_query_string(options)
    query = '?'
    options.each do |key, value|
      query += "#{key}=#{value.to_s.gsub(" ", "+")}&"
    end
    query[0...-1]
  end

  def post(url, data)
    response_data = HTTParty.post(url, :body => data)
    {
      body: response_data,
      response: response_data.code
    }
  end

  def get(url)
    c = HTTParty.get(url)
    { body: c, response: c.code }
  end

  def put(url, data={})
    c = HTTParty.put(url, :body => data, :headers => {
                          'Accept' => 'application/json',
                          'Content-Type' => 'application/json',
                          'Api-Version' => '2.2'
                        })
    { body: c, response: c.code }
  end
end

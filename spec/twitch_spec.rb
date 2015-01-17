require 'spec_helper'

describe Twitch do
  let(:client_id) { '' }
  let(:secret_key) { '' }
  let(:redirect_uri) { 'http://localhost:3000/auth' }
  let(:scope) { %w(user_read channel_read channel_editor channel_commercial channel_stream user_blocks_edit) }
  let(:scope_str) { scope.join('+') }
  let(:access_token) { '' }

  it 'should build accurate link' do
    twitch = Twitch.new(
      client_id: client_id,
      secret_key: secret_key,
      redirect_uri: redirect_uri,
      scope: scope
    )
    expect(twitch.get_link).to eq("https://api.twitch.tv/kraken/oauth2/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope_str}")
  end

  it 'should get user (not authenticated)' do
    expect(Twitch.new.get_user('day9')[:response]).to eq(200)
  end

  it 'should get user (authenticated)' do
    expect(Twitch.new(access_token: access_token).get_user('day9')[:response]).to eq(200)
  end

  it 'should get authenticated user' do
    expect(Twitch.new(access_token: access_token).get_your_user[:response]).to eq(200)
  end

  it 'should not get authenticated user when not authenticated' do
    expect(Twitch.new.get_your_user).to eq(false)
  end

  it 'should get all teams' do
    expect(Twitch.new.get_teams[:response]).to eq(200)
  end

  it 'should get single team' do
    expect(Twitch.new.get_team('eg')[:response]).to eq(200)
  end

  it 'should get single channel' do
    expect(Twitch.new.get_channel('day9tv')[:response]).to eq(200)
  end

  it 'should get your channel' do
    expect(Twitch.new(access_token: access_token).get_your_channel[:response]).to eq(200)
  end

  it 'should edit your channel' do
    expect(Twitch.new(access_token: access_token).edit_channel('Changing API', 'Diablo III')[:response]).to eq(200)
  end

  # it 'should run a comercial on your channel' do
  # 	@t = Twitch.new({:access_token => @access_token})
  # 	@t.runCommercial("dustinlakin")[:response].should == 204
  # end

  it 'should get a single user stream' do
    expect(Twitch.new.get_stream('nasltv')[:response]).to eq(200)
  end

  it 'should get all streams' do
    expect(Twitch.new.get_streams[:response]).to eq(200)
  end

  it 'should get League of Legends streams with +' do
    expect(Twitch.new.get_streams(game: 'League+of+Legends')[:response]).to eq(200)
  end

  it 'should get League of Legends streams with spaces' do
    expect(Twitch.new.get_streams(game: 'League of Legends')[:response]).to eq(200)
  end

  it 'should get featured streams' do
    response = Twitch.new.get_featured_streams
    expect(response[:response]).to eq(200)
    expect(response[:body]['featured'].length).to eq(25)
  end

  it 'should get featured streams' do
    response = Twitch.new.get_featured_streams(limit: 100)
    expect(response[:response]).to eq(200)
    expect(response[:body]['featured'].length).to be > 25
  end

end

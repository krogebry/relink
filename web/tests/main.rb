require './api.rb'
require 'rack/test'

LDAP_USER = {
  username: 'bkroger@CYBRAICS.COM',
  password: File.read(format('%s/.ad_pass', ENV['HOME'])).chomp
}.freeze

def login
  post '/login', username: LDAP_USER[:username], password: LDAP_USER[:password]
  expect(last_response.redirect?).to be true
end

describe 'login interactions' do
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end

  it 'redirects from unauthenticated /' do
    get '/'
    expect(last_response.redirect?).to be true
    follow_redirect!
    expect(last_request.path).to eq('/login')
  end

  it 'user can login' do
    login
    follow_redirect!
    expect(last_response.status).to be 200
    expect(last_request.path).to eq('/')
    expect(last_response.body).to include(format('Logged in as %s', LDAP_USER[:username]))
  end
end

describe 'health checks and maint' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'healthz works' do
    get '/healthz'
    expect(last_response.status).to eq 200
    json = JSON.parse last_response.body
    expect(json['success']).to eq true
  end

  it 'cache flush works' do
    get '/flush_cache'
    expect(last_response.status).to eq 302
  end
end

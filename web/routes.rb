get '/healthz' do
  { success: true }.to_json
end

get '/connz' do
  success = false
  messages = []
  { success: success, messages: messages }.to_json
end

get '/metrics' do
  {}.to_json
end

get '/flush_cache' do
  DevOps::Cache.flush
end

get '/' do
  links = MDB[:links].find().limit(10)
  erb :index, locals: { :links => links }
end

get '/create' do
  erb :create
end

get '/favicon.ico' do
  ''
end

get '/:key' do
  LOG.debug(format('Searching for %s', params[:key]))
  search = MDB[:links].find({ name: params[:key] })
  if search.count == 0
    erb :index, locals: { name: params[:key] }
  else
    redirect search.first['link']
  end
end

post '/relink' do
  pp params
  doc = {
    link: params['source_link'],
    name: params['friendly_name']
  }
  MDB[:links].insert_one doc
  #{ success: true }.to_json
  redirect '/'
end

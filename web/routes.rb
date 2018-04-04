get '/healthz' do
  { success: true }.to_json
end

get '/connz' do
  begin
    res = MDB[:links].find().limit(1).count
    if res
      test_db = format('Connected to db!' )
    else
      test_db = 'Query failed'
    end

  rescue Mongo::Error::NoServerAvailable => e
    test_db = e.class
  rescue => e
    test_db = 'Generic failure'
  end

  { success: true, info: {
      :db_test => test_db,
      :db_hostname => DB_HOSTNAME
  }}.to_json
end

get '/metrics' do
  {}.to_json
end

get '/version' do
  { :version => VERSION }.to_json
end

get '/flush_cache' do
  DevOps::Cache.flush
end

get '/' do
  links = MDB[:links].find().limit(10)
  erb :index, locals: { :links => links }
end

get '/create' do
  erb :link, locals: { message: 'Create new link' }
end

get '/favicon.ico' do
  ''
end

get '/backup' do
  links = MDB[:links].find().map{|l| l.to_h }
  {links: links}.to_json
end

post '/restore' do
  links = params[:links]
  links.each do |link|
    LOG.debug(format('Restoring link: %s', link['name']))
  end
end

get '/:key' do
  LOG.debug(format('Searching for %s', params[:key]))
  search = MDB[:links].find({ name: params[:key] })
  if search.count == 0
    redirect '/'
    #erb :index, locals: { name: params[:key] }
  else
    redirect search.first['link']
  end
end

get '/:link_id/edit' do
  search = MDB[:links].find({ _id: BSON::ObjectId(params[:link_id]) })
  erb :link, locals: { link: search.first, message: 'Edit link.' }
end

get '/:link_id/delete' do
  search = MDB[:links].find({ _id: BSON::ObjectId(params[:link_id]) })
  # erb :link, locals: { link: search.first, message: 'Edit link.' }
  MDB[:links].delete_one(_id: search.first['_id'])
  redirect '/'
end


post '/relink' do
  doc = {
    link: params['source_link'],
    name: params['friendly_name']
  }

  if params['link_id']
    LOG.debug('Updating')
    MDB[:links].update_one({ _id: BSON::ObjectId(params['link_id']) }, doc)
  else
    MDB[:links].insert_one doc
  end
  redirect '/'
end

class AuthorizationController < Sinatra::Application
  get '/logout' do
    logout!
    redirect '/'
  end

  get '/reauth' do
    authenticate!
    redirect '/'
  end

  get '/auth/:provider/callback' do
    content_type :json

    auth_hash = request.env['omniauth.auth']
    session[:authenticated] = true
    session[:auth_hash] = auth_hash
    redirect "/"
  end
end


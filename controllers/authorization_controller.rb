
module AuthorizationController

  def self.included(base)
    base.extend ClassMethods
    base.add_routes
  end

  module ClassMethods

    def add_routes
      helpers do
        def sample_oauth
          if File.exist? "dev_data/oauth_token"
            IO.read('dev_data/oauth_token').strip
          else
            ENV["OAUTH_TOKEN"]
          end
        end

        def sample_auth_hash
          { "credentials" => { "token"    => sample_oauth },
            "info"        => { "nickname" => "wstrinz"    } }
        end

        def authenticated?
          session[:authenticated]
        end

        def ensure_authenticated
          unless authenticated?
            authenticate!
          end
        end

        def authenticate!
          unless self.class.production?
            session[:authenticated] = true
            session[:auth_hash] = sample_auth_hash
          else
            redirect '/auth/github'
          end
        end

        def logout!
          session.clear
        end
      end

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
  end

end


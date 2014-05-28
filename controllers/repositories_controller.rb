module RepositoriesController
  def self.included(base)
    base.extend ClassMethods
    base.add_routes
  end

  module ClassMethods
    def add_routes
      helpers do
        def sample_repos
          JSON.parse(IO.read('dev_data/repos.json'))
        end

        def repos(info_hash)
          GithubHelper.repos(info_hash)
        end
      end

      get '/repositories' do
        ensure_authenticated
        content_type :json
        repos(session[:auth_hash]).to_json
      end
    end
  end
end


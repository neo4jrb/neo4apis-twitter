require 'twitter'

module Neo4Apis
  module CLI
    class Twitter < Thor
      class_option :config_path, type: :string,  default: 'config/twitter.yml'

      desc "filter TRACK", "Streams tweets via a filter"
      def filter(track)
        neo4apis_client.batch do
          twitter_client(true).filter(track: track, &tweet_importer)
        end
      end

      option :geocode, type: :string
      option :lang, type: :string
      option :locale, type: :string
      option :result_type, type: :string
      option :until, type: :string
      desc "search QUERY COUNT", "Import tweets via a search query"
      def search(query, count)
        neo4apis_client.batch do
          twitter_client(false).search(query, options).take(count.to_i).each(&tweet_importer)
        end
      end

      private

      def tweet_importer
        Proc.new do |object|
          case object
          when ::Twitter::Tweet
            say "got tweet from @#{object.user.screen_name}: #{object.text}"
            neo4apis_client.import :Tweet, object
          when ::Twitter::Streaming::StallWarning
            puts "Falling behind!"
          end
        end
      end

      NEO4APIS_CLIENT_CLASS = ::Neo4Apis::Twitter    

      def neo4apis_client
        @neo4apis_client ||= NEO4APIS_CLIENT_CLASS.new(Neo4j::Session.open(:server_db, parent_options[:neo4j_url]), import_retweets: true, import_hashtags: true)
      end

      def twitter_client(streaming)
        return @twitter_client if @twitter_client

        twitter_client_class = streaming ? ::Twitter::Streaming::Client : ::Twitter::REST::Client

        @twitter_client = twitter_client_class.new do |config|
          yml_config.each do |key, value|
            config.send("#{key}=", value)
          end
        end
      end

      # For reference for this gem's documentation:
      # https://github.com/sferik/twitter/blob/master/examples/Configuration.md
      def yml_config
        require 'yaml'
        @yml_config ||= YAML.load(File.open(options[:config_path]).read)
      end
    end

    class Base < Thor
      desc "twitter SUBCOMMAND ...ARGS", "methods of importing data automagically from Twitter"
      subcommand "twitter", CLI::Twitter
    end
  end
end


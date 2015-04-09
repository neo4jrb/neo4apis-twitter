require 'twitter'
require 'thor'
require 'colorize'

module Neo4Apis
  module CLI
    class Twitter < Base
      class_option :config_path, type: :string,  default: 'config/twitter.yml'

      class_option :import_retweets, type: :boolean, default: false
      class_option :import_hashtags, type: :boolean, default: false
      class_option :import_user_mentions, type: :boolean, default: false

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
      option :count, type: :numeric
      desc "search QUERY COUNT", "Import tweets via a search query"
      def search(query, count)
        neo4apis_client.batch do
          twitter_client.search(query, options).take(count.to_i).each(&tweet_importer)
        end
      end

      desc "followers USERNAME DEPTH", "Imports followers (and optionally followers of followers if depth specified and with a value > 1"
      def followers(user, depth = 1)
        neo4apis_client.batch do
          follower_importer(neo4apis_client, user, depth.to_i)
        end
      end

      desc "friends USERNAME DEPTH", "Imports friends (and optionally friends of friends if depth specified and with a value > 1"
      def friends(user, depth = 1)
        neo4apis_client.batch do
          friend_importer(neo4apis_client, user, depth.to_i)
        end
      end

      private

      def follower_importer(neo4apis_client, user, depth)
        friend_follower_importer(:followers, neo4apis_client, user, depth)
      end

      def friend_importer(neo4apis_client, user, depth)
        friend_follower_importer(:friends, neo4apis_client, user, depth)
      end

      def friend_follower_importer(type, neo4apis_client, user, depth)
        twitter_user = if user == ::Twitter::User
                         user
                       else
                         throttled_block { twitter_client.user(user) }
                       end
        user_node = user_importer.call(twitter_user)

        relationship = (type == :friends ? :friended : :follows)
        get_friends_or_followers(type, twitter_user).each do |other_user|
          other_user_node = user_importer.call(other_user)

          neo4apis_client.add_relationship(relationship, other_user_node, user_node)

          if depth > 1
            friend_follower_importer(type, neo4apis_client, other_user, depth - 1)
          end
        end
      end

      def get_friends_or_followers(type, user)
        [].tap do |user_list|
          next_cursor = -1
          while next_cursor != 0
            result = throttled_block { twitter_client.send(type, user, cursor: next_cursor, count: 5000) }
            throttled_block { user_list.concat(result.take(5000)) }
            next_cursor = result.send(:next_cursor)
          end
        end
      end

      def throttled_block
        yield
      rescue ::Twitter::Error::TooManyRequests => error
        reset_in = error.rate_limit.reset_in
        puts "Rate limit exceeded.  Sleeping for #{reset_in} seconds"

        neo4apis_client.instance_variable_get('@buffer').flush
        sleep reset_in
        retry
      end

      def tweet_importer
        @tweet_importer ||= object_importer(::Twitter::Tweet, :Tweet)
      end

      def user_importer
        @user_importer ||= object_importer(::Twitter::User, :User)
      end

      def object_importer(gem_class, label)
        Proc.new do |object|
          case object
          when gem_class
            case label
            when :Tweet
              say "got tweet from @#{object.user.screen_name.colorize(:light_blue)}: #{object.text}"
            when :User
              say "get user ##{object.id}"
            end
            neo4apis_client.import label, object
          when ::Twitter::Streaming::StallWarning
            say "FALLING BEHIND!".colorize(:red)
          end
        end
      end

      NEO4APIS_CLIENT_CLASS = ::Neo4Apis::Twitter

      def neo4apis_client
        @neo4apis_client ||= NEO4APIS_CLIENT_CLASS.new(specified_neo4j_session, import_retweets: options[:import_retweets], import_hashtags: options[:import_hashtags], import_user_mentions: options[:import_user_mentions])
      end

      def twitter_client(streaming = false)
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
        return @yml_config if @yml_config

        require 'yaml'
        data = File.open(options[:config_path]).read

        require 'erb'
        data = ERB.new(data).result(binding)

        @yml_config ||= YAML.load(data)
      end
    end

    class Base < Thor
      desc "twitter SUBCOMMAND ...ARGS", "methods of importing data automagically from Twitter"
      subcommand "twitter", CLI::Twitter
    end
  end
end


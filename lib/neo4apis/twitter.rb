require 'neo4apis'

module Neo4Apis
  class Twitter < Base
    PREFIX = 'twitter'

    def initialize(neo4j_client, options = {})
      @client = options[:twitter_client]

      raise ArgumentError, "Invalid client: #{@client.inspect}" if not @client.is_a?(::Twitter::REST::Client)

      options[:uuids] = (options[:uuids] || {}).merge({
        Tweet: :id,
        User: :id
      })

      super(neo4j_client, options)
    end

    def import_search(*args)
      @client.search(*args).take(100).each do |tweet|
        add_tweet(tweet)
      end
    end

    private
    
    def add_tweet(tweet)
      user_node = add_user(tweet.user)
      retweeted_tweet_node = add_tweet(tweet.retweeted_tweet) if tweet.retweeted_tweet?

      node = add_node :Tweet, {
        id: tweet.id,
        text: tweet.text,
      }

      add_relationship(:tweeted, user_node, node)
      add_relationship(:retweets, node, retweeted_tweet_node) if tweet.retweeted_tweet?

      node
    end

    def add_user(user)
      add_node :User, {
        id: user.id,
        screen_name: user.screen_name,
        name: user.name,
        location: user.location,
        profile_image_url: user.profile_image_url.to_s
      }
    end

  end
end


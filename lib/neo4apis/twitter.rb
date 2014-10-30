require 'neo4apis'

module Neo4Apis
  class Twitter < Base
    uuid :Tweet, :id
    uuid :User, :id

    importer :Tweet do |tweet|
      user_node = import :User, tweet.user

      retweeted_tweet_node = import :Tweet, tweet.retweeted_tweet if options[:import_retweets] && tweet.retweeted_tweet?

      node = add_node :Tweet, {
        id: tweet.id,
        text: tweet.text,
      }

      add_relationship(:tweeted, user_node, node)
      add_relationship(:retweets, node, retweeted_tweet_node) if options[:import_retweets] && tweet.retweeted_tweet?

      node
    end

    importer :User do |user|
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


require 'neo4apis'
require 'ostruct'

module Neo4Apis
  class Twitter < Base
    common_label :Twitter

    uuid :Tweet, :id
    uuid :User, :id
    uuid :HashTag, :text

    batch_size 1000

    importer :Tweet do |tweet|
      user_node = import :User, tweet.user

      retweeted_tweet_node = import :Tweet, tweet.retweeted_tweet if options[:import_retweets] && tweet.retweeted_tweet?

      node = add_node :Tweet, tweet, %w{id text reply? geo urls media lang source favorite_count retweet_count created_at}

      if options[:import_hashtags] && tweet.respond_to?(:hashtags)
        tweet.hashtags.each do |hashtag|
          hashtag_node = import :HashTag, hashtag

          add_relationship :has_hashtag, node, hashtag_node, text: hashtag.text
        end
      end

      if options[:import_user_mentions] && tweet.respond_to?(:user_mentions)
        tweet.user_mentions.each do |user_mention|
          user_mention_node = import :User, OpenStruct.new(user_mention.attrs)

          add_relationship :mentions_user, node, user_mention_node
        end
      end

      add_relationship :tweeted, user_node, node
      add_relationship :retweets, node, retweeted_tweet_node if options[:import_retweets] && tweet.retweeted_tweet?


      node
    end

    importer :User do |user|
      add_node(:User, user, %w{id screen_name name description location profile_image_url created_at utc_offset time_zone lang followers_count verified? geo_enabled?}) do |node|
        node.profile_image_url = user.profile_image_url.to_s
      end
    end

    importer :HashTag do |hashtag|
      add_node :HashTag do |node|
        node.text = hashtag.text.downcase
      end
    end

  end

end


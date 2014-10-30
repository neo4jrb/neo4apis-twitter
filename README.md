
neo4apis-twitter is a ruby gem for making importing data from twitter to neo4j easy

This adapter supports objects created from the `twitter` gem.

```ruby

twitter_client = Twitter::REST::Client.new ...

neo4japis_twitter = Neo4Apis::Twitter.new(Neo4j::Session.open, import_retweets: true)

neo4japis_twitter.batch do 
  twitter_client.search("ebola", :result_type => "recent").take(100).each do |tweet|
    # Imports:
    #  * The tweet
    #  * The tweeter, 
    #  * The original tweet if a retweet
    #  * The user for the original tweet
    import :Tweet, tweet
  end
end

```



neo4apis-twitter is a ruby gem for making importing data from twitter to neo4j easy

The `twitter` gem is used and thus the methods in this API try to match that API as closely as possible

```ruby

twitter_client = Twitter::REST::Client.new ...

neo4japis_twitter = Neo4Apis::Twitter.new(Neo4j::Session.open, twitter_client: twitter_client)

neo4japis_twitter.batch do
  neo4japis_twitter.import_search("ebola", :result_type => "recent")
end

```


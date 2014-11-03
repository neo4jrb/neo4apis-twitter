
### Introduction

neo4apis-twitter is a ruby gem for making importing data from twitter to neo4j easy

This adapter supports objects created from the `twitter` gem.  Currently supports importing User and Tweet

You can either use the gem to write custom ruby code to import data or you can simply use the command-line interface.

### Installation

`gem 'neo4apis-twitter'` in your Gemfile or `gem install neo4apis-twitter`

#### Ruby code

```ruby

twitter_client = Twitter::REST::Client.new ...

neo4japis_twitter = Neo4Apis::Twitter.new(Neo4j::Session.open,
                                          import_retweets: true,
                                          import_hashtags: true)

neo4japis_twitter.batch do 
  twitter_client.search("ebola", :result_type => "recent").take(100).each do |tweet|
    # Imports:
    #  * The tweet
    #  * The tweeter, 
    #  * The original tweet if a retweet
    #  * The user for the original tweet
    neo4apis_client.import :Tweet, tweet
  end
end

```

#### Command Line

Import tweets as a stream:

`neo4apis twitter filter TRACK`

Import tweets via a search query:

`neo4apis twitter search QUERY COUNT`

Supports optional arguments from the [twitter API](https://dev.twitter.com/rest/reference/get/search/tweets):

`neo4apis twitter search QUERY COUNT --result-type=[mixed|recent|popular]`

Supported options:
 * `geocode`
 * `lang`
 * `locale`
 * `result_type`
 * `until`

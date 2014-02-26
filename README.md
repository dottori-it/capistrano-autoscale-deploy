# Capistrano AutoScale Deploy

Capistrano plugin that enable discovery of instances in ec2 AutoScale groups into capistrano deployment script.

## Requirements

* aws-sdk
* capistrano ~> 2.15.5


## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-autoscale-deploy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-autoscale-deploy

Add this line to your application's Capfile:

```ruby
require 'capistrano/autoscale_deploy'
```

And set credentials with AmazonEC2ReadOnlyAccess permission in config/deploy.rb as:

```ruby
set :access_key_id, "YOUR ACCESS KEY ID"
set :secret_access_key, "YOUR SECRET ACCESS KEY"
set :region, "eu-west-1"
```

## Usage

In the capistrano deploy script / stage files add the following line

```ruby
autoscale :AutoScaleGroup => 'name of your autoscale group (by Name tag)', :deploy_roles => [:app, :web, :db, :primary => true]
```

you can add more autoscale configs to deploy to multiple autoscale groups like a cluster


## Contributing

1. Fork it ( http://github.com/<my-github-username>/capistrano-ec2_tagged/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

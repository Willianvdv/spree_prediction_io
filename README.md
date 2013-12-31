Spree Prediction Io
===

Do not use this gem yet :)


Installation
------------

### PredictionIo

See the predictionIo site for installation instructions: [http://docs.prediction.io/current/installation/index.html](http://docs.prediction.io/current/installation/index.html)

### Spree Prediction Io

Add spree_prediction_io to your Gemfile:

```ruby
gem 'spree_prediction_io'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_prediction_io:install
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_prediction_io/factories'
```

Copyright (c) 2013 [name of extension creator], released under the New BSD License

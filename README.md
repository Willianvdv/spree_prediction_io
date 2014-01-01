Spree Prediction Io
===

I want to use predictionio's recommendation engines for my Spree shops. This gem provides tasks to upload user, product and conversions. Step 2 is to retrieve the computed data from PredictionIo and present that to my users.


Installation
------------

### PredictionIo

See the predictionIo site for installation instructions: [http://docs.prediction.io/current/installation/index.html](http://docs.prediction.io/current/installation/index.html)

### Spree Prediction Io

Add spree_prediction_io to your Gemfile:

```ruby
gem 'spree_prediction_io' github: 'Willianvdv/spree_prediction_io'
```

Sync your data
---

Sync users and products

```
$ bundle exec rake predictionio:sync:all
```

Sync users:

```
$ bundle exec rake predictionio:sync:users
```

Sync products: 

```
$ bundle exec rake predictionio:sync:products
```

Copyright (c) 2014 Willian van der Velde, released under the New BSD License

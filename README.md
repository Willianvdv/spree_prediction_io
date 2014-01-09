Spree Prediction IO
===

[![Build Status](https://travis-ci.org/Willianvdv/spree_prediction_io.png?branch=master)](https://travis-ci.org/Willianvdv/spree_prediction_io)

I want to use PredictionIO's recommendation engines for my Spree shops. This gem provides tasks to upload user, product and conversions. Step 2 is to retrieve the computed data from PredictionIO and present that to my users.


Installation
------------

### PredictionIO

See the PredictionIO site for installation instructions: [http://docs.prediction.io/current/installation/index.html](http://docs.prediction.io/current/installation/index.html)

### Spree Prediction IO

Add spree_prediction_io to your Gemfile:

```ruby
gem 'spree_prediction_io' github: 'Willianvdv/spree_prediction_io'
```

Place your PredictionIO api key in `config/application.yml`. For now I'm using Figaro, in the future I will use the Spree configuration.

Sync your data
---

### Push data

```
$ bundle exec rake predictionio:push:all
```

### Pull data

To pull similar products (engine status must be `Running`):

```
$ bundle exec rake predictionio:pull:similar_products[my_engine_name]
```

This will create related products. To give you an idea, it will be something like this:

```
PS3 Sony Dualshock 3 Slate Grey relates to:
	- PS3 Sony Dualshock 3 Urban Camouflage
	- PS3 Sony Dualshock 3 Metallic Gold
	- Grand Theft Auto V
	- FIFA 14
```

To pull recommendations for users:

```
$ bundle exec rake predictionio:pull:recommendations[my_engine_name]
```

This will return something like this:

```
Recommended products for 216 (john.doe@example.com):
  - PlayStation 3
  - PS3 Sony Dualshock 3 Urban Camouflage
  - PS3 Sony Dualshock 3 Metallic Gold
```

---

Copyright (c) 2014 Willian van der Velde, released under the New BSD License

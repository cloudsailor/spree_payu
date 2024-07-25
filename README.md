Spree PayU
====================

This is fork of matfiz/spree_payu
PayU payment system for Spree (>= 4.5)

Install
=======

Add to your Gemfile:

    gem 'spree_payu', github: 'cloudsailor/spree_payu'

and run

    bundle install

PayU.pl Settings
========

You'll have to set the following parameters:
  * payu_client_id
  * payu_pos_id
  * payu_second_key
  * payu_client_secret
  * return_url
  * return_status_url

In Spree Admin zone you have to create new payment method and select *Spree::Gateway::Payu* as a provider.
I recommend to test it first - just select *test mode* in payment method settings and it will use sandbox platform instead of the production one.

------------------------------------------------------------------------------
License
------------------------------------------------------------------------------

Copyright (c) 2024 - Cloud Sailor AS, released under the New BSD License All rights reserved.

Spree PayU
====================

PayU payment system for Spree (>= 5.0.0). Allows to define separately following payment methods:
- PayU
- Payu Raty
  - Polish payments only
  - 300,00 - 20000,00 PLN*
- PayPo
  - Polish payments only 
  - 10,00 - 6000,00 PLN

\*w depends on variant.

The last Spree 4 supporting release is 1.7.0.

Install
=======

Add to your Gemfile:

    gem 'spree_payu'

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

Official Docs Reference
========
https://developers.payu.com/europe/pl/docs/get-started/
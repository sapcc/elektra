monsoon-dashboard
=================

New service based Monsoon dashboard.

Prerequisites
-------------
1. running Authority
2. installed postgres database

Install
-------
this is work in progress so no guarantee of completeness ;-)

1. bundle install
2. copy env.sample to .env and adjust the values
3. rake db:create
4. rake db:seed
5. foreman start
6. now try to access http://localhost:8180

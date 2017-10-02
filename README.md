Redmine Auto Assign Group Plugin
================================

This is Redmine plugin which assigns group automatically when create new users.


Project Health
==============
[![Build Status](https://travis-ci.org/two-pack/redmine_auto_assign_group.svg?branch=master)](https://travis-ci.org/two-pack/redmine_auto_assign_group) [![Code Climate](https://codeclimate.com/github/two-pack/redmine_auto_assign_group.png)](https://codeclimate.com/github/two-pack/redmine_auto_assign_group)

Requirements
============

* Redmine 3.3.x or higher.
* Ruby 2.x

Installation
============

In Redmine folder,
```
$ cd plugins
$ git clone https://github.com/two-pack/redmine_auto_assign_group.git redmine_auto_assign_group
$ cd ..
$ bundle install --without test
$ bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```
Finally restart Redmine.

Usage
=====

1. Log in Redmine with Admistrator.
2. Go to **Administration - Groups**.
3. Select group which you want to add rules.
4. Go to **Rules** tab.  
   You can manage rule for assigning groups.

After settings, this plugin automatically assigns groups for new user according to rules.

See [Wiki](https://github.com/two-pack/redmine_auto_assign_group/wiki/Usage) for details.

License
=======

This plugin is released under the GPL v2 license. See LICENSE.txt for more information.

Copyright
=========

Copyright (C) 2017 Tatsuya Saito.
## Fleet Management Backend Application

### Description
This is a small-scale fleet management system where
 vehicles make deliveries to predetermined locations along a certain route.  two different types of shipments that can be transported in vehicles
 and unloaded at delivery points: Package and Bag. Vehicles have license plates registered in the system. 

 The system includes three different delivery points.
- Branch: Only package-type shipments can be unloaded. Bags and packages in bags
may not be unloaded.
- Distribution Center: Bags, packages in bags and packages not assigned to any bags
may be unloaded.
- Transfer Center: Only bags and packages in bags may be unloaded.

Vehicles must go to their assigned delivery points and ensure that the relevant
 shipments are unloaded at the relevant delivery points.


### Built With

- Ruby, Ruby on Rails
- PostgreSQL

### Getting Started
####  Installation
To run in local environment, follow the steps:
 - brew install ruby2.7
 - brew install postgresql
 - git clone https://github.com/cnsvr/trendyol-fleet-management-system
 - cd https://github.com/cnsvr/trendyol-fleet-management-system/fleet-management-api
 - bundle install
 - rails db:create
 - rails db:migrate
 - rails server

 it will serve on the http://localhost:3000
 
 To run with Docker
 - git clone https://github.com/cnsvr/trendyol-fleet-management-system
 - https://github.com/cnsvr/trendyol-fleet-management-system/fleet-management-api
 - docker-compose build
 - docker-compose up

 it will serve on the http://localhost:3000

### Testing
- All lines are tested with [SimpleCov](https://github.com/simplecov-ruby/simplecov) gem.
- To run tests in local environment, follow the steps:
     * rails test
     * open coverage/index.html

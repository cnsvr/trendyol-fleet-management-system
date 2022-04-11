class HomeController < ApplicationController
  def index
    @title = 'Home'
    render plain: "Welcome to the Fleet Management API"
  end
end
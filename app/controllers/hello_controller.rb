class HelloController < ApplicationController
  include Authentication

  def index
    render html: "<h1>Hello</h1>"
  end
end
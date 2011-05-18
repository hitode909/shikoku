# -*- coding: utf-8 -*-
require 'mongo'

module Shikoku
  class Database
    class << self
      def database
        @collection ||= Mongo::Connection.new('localhost', 27017, :pool_size => 5, :timeout => 5).db("shikoku")
      end

      def token
        database.collection('token')
      end
    end
  end
end

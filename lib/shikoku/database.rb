# -*- coding: utf-8 -*-
require 'mongo'
require 'logger'

module Shikoku
  class Database
    class << self
      def collection(mime_type)
        database.collection(mime_type)
      end

      private
      def database
        @collection ||= Mongo::Connection.new('localhost', 27017).db("shikoku")
      end

    end
  end
end

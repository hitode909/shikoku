# -*- coding: utf-8 -*-
require 'mongo'
require 'logger'

module Shikoku
  class Database
    class << self
      def database
        # logger = Logger.new($stdout)
        # logger.level = Logger::DEBUG
        # , :logger => logger
        @collection ||= Mongo::Connection.new('localhost', 27017).db("shikoku")
      end

      def collection(mime_type)
        database.collection(mime_type)
      end
    end
  end
end

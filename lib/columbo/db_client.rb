require 'mongo'

module Columbo
  class DbClient
    include Mongo

    attr_accessor :coll

    def initialize(uri)
      client = Mongo::MongoClient.from_uri(uri)
      db = client[uri.split('/').last]
      @coll  = db[Columbo::MONGO_COLLECTION]
    end

    def insert(*args)
      coll.insert *args
    end

    def save(*args)
      coll.findOne *args
    end

    def find(*args)
      coll.find *args
    end

    def find_one(*args)
      coll.find_one *args
    end

    def remove(*args)
      coll.remove *args
    end

    def update(*args)
      coll.update *args
    end
  end
end
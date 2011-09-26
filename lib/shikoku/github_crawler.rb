require "nokogiri"
require "uri"
require "open-uri"

module Shikoku
  class GithubCrawler

    def self.each(lang = 'Ruby')
      (0..(1/0.0)).each{ |page|
        doc = Nokogiri open("https://github.com/languages/#{lang}/created?page=#{page}")
        doc.search('.title').each{ |line|
          path = line.search('a')[0]['href']
          yield "git://github.com#{path}.git"
        }
      }
    end
  end
end

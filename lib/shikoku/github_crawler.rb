require "nokogiri"
require "uri"
require "open-uri"

module Shikoku
  class GithubCrawler

    def self.each(lang = 'Ruby')
      warn "lang: #{lang}"
      (0..(1/0.0)).each{ |page|
        doc = Nokogiri open("https://github.com/languages/#{lang}/most_watched?page=#{page}")
        doc.search('.title').each{ |line|
          path = line.search('a')[0]['href']
          yield "git://github.com#{path}.git"
        }
      }
    end
  end

  class RailsCrawler

    def self.each(lang = 'Ruby')
      (1..(1/0.0)).each{ |page|
        doc = Nokogiri open("https://github.com/search?langOverride=&language=Ruby&q=rails&repo=&start_value=#{page}&type=Repositories&x=0&y=0")
        p doc.at('.title')
        doc.search('.title').each{ |line|
          begin
            path = line.search('a')[0]['href']
            yield "git://github.com#{path}.git"
          rescue => error
            warn 'skip'
          end
        }
      }
    end
  end
end

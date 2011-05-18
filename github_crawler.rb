require "rubygems"
require "bundler/setup"
require "open-uri"
require "nokogiri"
require "uri"

class GithubCrawler
  HOST = URI.parse 'https://github.com/'

  def self.crawl
    (0..(1/0.0)).each{ |page|
      puts "page #{page}"

      doc = Nokogiri open("https://github.com/languages/Ruby/created?page=#{page}")

      doc.search('.title').each{ |line|
        slug = line.search('a')[1]['href']
        yield GithubRepository.new_from_slug(slug)
      }
    }
  end
end

class GithubRepository
  LOCAL_ROOT = File.expand_path "~/scc/" # TODO: Config

  def initialize owner, name
    raise "owner is empty #{[owner, name]}" if owner.empty?
    raise "name is empty #{[owner, name]}" if name.empty?
    @owner = owner
    @name = name
  end

  def self.new_from_slug slug
    self.new *slug.split('/').delete_if(&:empty?)
  end

  def setup
    if has_local?
      git_pull
    else
      git_clone
    end
  rescue => error
    warn error
  end

  def slug
    [@owner, @name].join('/')
  end

  def local_path
    File.join LOCAL_ROOT, [@owner, @name].join('-')
  end

  def has_local?
    Dir.exists? local_path
  end

  def git_pull
    puts "pull #{slug}"
    Dir.chdir local_path
    system "git pull origin master" or raise "git pull returns #{$?}"
  end

  def git_clone
    puts "clone #{slug}"
    system "git clone #{git_url} #{local_path}" or raise "git clone returns #{$?}"
  end

  def git_url
    "git://github.com/#{@owner}/#{@name}.git"
  end
end

GithubCrawler.crawl{ |repos|
  repos.setup
}

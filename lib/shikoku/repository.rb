# -*- coding: utf-8 -*-
require 'digest/sha1'
require 'grit'

module Shikoku
  class Repository
    ROOT = File.expand_path "~/shikoku/"
    attr_reader :local_path, :remote_url

    def initialize(args)
      @local_path = args[:local_path]
      @remote_url = args[:remote_url]

      if remote_url
        @local_path = extract_local_path @remote_url
      elsif local_path
        @remote_url = grit.config["remote.origin.url"]
      else
        raise "remote_url or local_path is neccessary" unless remote_url or local_path
      end
      self
    end

    # cloneもできる
    # local_pathはremote_urlから決定
    def self.new_from_remote(remote_url)
      self.new :remote_url => remote_url
    end

    # 普通はこっち
    # remote_urlはGrit::Repoから取れるけどなくてもいいはず
    def self.new_from_local(local_path)
      self.new :local_path => local_path
    end

    def self.all_path
      Dir.glob(File.join(ROOT, '*'))
    end

    def self.all
      Dir.glob(File.join(ROOT, '*')).map{ |path| self.new_from_local path }
    end

    # 最新状態に更新する
    def setup
      if has_local?
        git_pull
      else
        git_clone
      end
    end

    def tree(*args)
      grit.tree(*args)
    end

    # XXX: fileのことだけど，Fileクラス作ると組込みのFileクラスと名前が被る
    def entries
      grit.git.native(:ls_files).split(/\n/).map{ |path|
        Shikoku::Entry.new(self, path)
      }
    end

    protected

    def grit
      @grit ||= Grit::Repo.init(local_path)
    end

    # remote urlからlocal path 作る，fallbackあり
    def extract_local_path(url)
      match = url.match(/[:\/]([^\/]+)\/([^\/]+)\.git$/)
      if match
        name = [match[1], match[2]].join('-')
      else
        warn "extract rule not matched for #{url}"
        name = Digest::SHA1.hexdigest(url)
      end
      File.join ROOT, name
    end

        def has_local?
      Dir.exists? local_path
    end

    def git_pull
      # Dir.mkdir(ROOT) unless Dir.exists? ROOT
      Dir.chdir local_path
      Shikoku::Utility.system_or_die "git pull origin master"
    end

    def git_clone
      puts "clone"
      Shikoku::Utility.system_or_die "git clone", remote_url, local_path
    end


  end
end

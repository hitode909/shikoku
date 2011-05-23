# -*- coding: utf-8 -*-
require 'digest/sha1'

module Shikoku
  class Entry
    attr_reader :repository, :path
    # repositoryから作る pathはリポジトリ内のpath
    def initialize(repository, path)
      @repository = repository
      @path = path
    end

    def full_path
      File.join(@repository.local_path, path)
    end

    def content
      blob.data.encode('utf-8')
    end

    # DBから引いてくる
    def tokens
      []
    end

    # 計算
    def create_tokens
      tokenizer.tokenize
    end

    def tokenizer
      @tokenizer ||= Shikoku::Tokenizer.new_from_path_and_mime_type(full_path, mime_type)
    end

    def db
      Shikoku::Database.collection(mime_type)
    end

    # 計算 + DBに保存
    def save_tokens
      return if has_records?
      db.insert(tokens_to_records(create_tokens))
      db.ensure_index([['value', Mongo::ASCENDING]])
      db.ensure_index([['url', Mongo::ASCENDING], ['path', Mongo::ASCENDING], ['mtime', Mongo::ASCENDING]])
    end

    def has_records?
      !! db.find_one(as_key)
    end

    # tokenのデータ構造ちゃんと決まってない，クラスにしたほうがよいかもしれない

    def tokens_to_records(tokens)
      tokens.each_with_index.map{|v, i|
        as_key.merge({
            :value => v,
            :index => i
          })
      }
    end

    # db.token.ensureIndex({url: 1, path: 1, mtime: 1})
    # db.token.ensureIndex({value: 1})
    def as_key
      @as_key ||= {
        :url   => repository.remote_url,
        :path  => path,
        :mtime => mtime,
        :mime_type => mime_type
      }
    end

    # これではチェックアウト時間に依るのでだめ
    # git logから取ってくるべき
    # あまりgitに依存するのもよくないのでこれで良い？
    # もしくは，コミットのsha1を使うとか
    def mtime
      @mtime ||= File.mtime full_path
    end

    def blob
      repository.tree/path
    end

    def mime_type
      return @mime_type if @mime_type
      # XXX
      if blob.kind_of? Grit::Submodule
        @mime_type = "git/submodule"
      else
        @mime_type = blob.mime_type
      end
    end
  end
end

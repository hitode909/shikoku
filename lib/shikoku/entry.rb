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
      open(full_path).read
    end

    FILETYPES = {
      /\.rb$/ => :ruby,
    }

    def filetype
      key = FILETYPES.keys.find{|rule|
        rule =~ path
      }
      FILETYPES[key] || :plain_text
    end

    # DBから引いてくる
    def tokens
      []
    end

    # 計算
    def create_tokens
      t = Shikoku::Tokenizer.new_from_path_and_filetype(full_path, filetype)
      t.tokenize
    end

    # 計算 + DBに保存
    def save_tokens
      return if has_records?
      Shikoku::Database.token.insert(tokens_to_records(create_tokens))
    end

    def has_records?
      !! Shikoku::Database.token.find_one(as_key)
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
      File.mtime full_path
    end

    def blob
      repository.tree/path
    end

    def mime_type
      blob.mime_type
    end
  end
end

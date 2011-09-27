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

    # 空白だけのトークンはDBに入れない
    def create_tokens_for_save
      create_tokens.select{ |s|
        s =~ /\S/
      }
    end

    def tokenizer
      @tokenizer ||= Shikoku::Tokenizer.new_from_path_and_mime_type(full_path, mime_type)
    end

    def db
      Shikoku::Database.collection(mime_type)
    end

    def files_db
      Shikoku::Database.collection(mime_type + "/files")
    end

    def file_summary_db
      Shikoku::Database.collection(mime_type + "/file_summary")
    end

    def count_summary_db
      Shikoku::Database.collection(mime_type + "/count_summary")
    end

    # どのファイルにでるか
    def file_token_db
      Shikoku::Database.collection(mime_type + "/file_token")
    end

    # 計算 + DBに保存
    def save_tokens
      return if has_records?
      list = create_tokens_for_save
      db.insert(tokens_to_records(list))
      list.each{ |v|
        count_summary_db.update({ :value => v}, { :$inc => { :count => 1}}, {:upsert => true})
      }
      list.uniq.each{ |v|
        file_summary_db.update({ :value => v}, { :$inc => { :count => 1}}, {:upsert => true})

        key = {
          :value => v,
          :url   => repository.remote_url,
          :path  => path,
        }
        file_token_db.update(key, key, {:upsert => true})
      }
      files_db.insert(as_key)
    end

    def create_index
      db.ensure_index([['value', Mongo::ASCENDING]])
      db.ensure_index([['url', Mongo::ASCENDING], ['path', Mongo::ASCENDING], ['mtime', Mongo::ASCENDING]])
      count_summary_db.ensure_index([['value', Mongo::ASCENDING]])
      file_summary_db.ensure_index([['value', Mongo::ASCENDING]])
      file_token_db.ensure_index([
          ['value', Mongo::ASCENDING],
          ['path', Mongo::ASCENDING],
          ['url', Mongo::ASCENDING],
        ])
    end

    def has_records?
      !! files_db.find_one(as_key)
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

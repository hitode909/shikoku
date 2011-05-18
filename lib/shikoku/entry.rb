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

    # DBから引いてくる
    def tokens
      []
    end

    # 計算
    def tokenize
      t = Shikoku::Tokenizer.new_from_path(full_path)
      t.tokenize
    end

    # 計算 + DBに保存
    def tokenize_and_record
      puts "save"
    end
  end
end

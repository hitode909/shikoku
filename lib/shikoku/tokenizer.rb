# -*- coding: utf-8 -*-
require 'digest/sha1'
require 'grit'
require 'ripper'

module Shikoku
  class Tokenizer
    attr_reader :path
    def initialize(path)
      @path = path
    end

    def self.new_from_path(path)
      class_for_filename(path).new(path)
    end

    def self.class_for_filename(filename)
      key = FILETYPES.keys.find{|rule|
        rule =~ filename
      }
      FILETYPES[key] || Basic
    end

    # --- common methods ---
    def content
      @content ||= open(path).read
    end

    # --- tokenizers ---

    class Basic < self
      def tokenize
        content.split(/\s+/m)
      end
    end

    class Ruby < self
      def tokenize
        Ripper.tokenize(content, path)
      end
    end

    FILETYPES = {
      /\.rb$/ => Ruby
    }
    # TODO: java, javascriptくらいは取れそう
    # TODO: ファイルタイプはファイルクラスが持つべき

  end
end

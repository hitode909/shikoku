# -*- coding: utf-8 -*-
require 'digest/sha1'
require 'grit'
require 'ripper'

module Shikoku
  class Tokenizer
    attr_reader :path
    def initialize(path, filetype)
      @path = path
      @filetype = filetype
    end

    def self.new_from_path_and_filetype(path, filetype)
      class_for_filetype(filetype).new(path, filetype)
    end

    def self.class_for_filetype(filetype)
      CLASSES[filetype] || Basic
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

    CLASSES = {
      :ruby => Ruby
    }

  end
end

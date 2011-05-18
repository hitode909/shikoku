# -*- coding: utf-8 -*-
require 'digest/sha1'
require 'grit'
require 'ripper'

module Shikoku
  class Tokenizer
    attr_reader :path
    def initialize(path, mime_type)
      @path = path
      @mime_type = mime_type
    end

    def self.new_from_path_and_mime_type(path, mime_type)
      class_for_mime_type(mime_type).new(path, mime_type)
    end

    def self.class_for_mime_type(mime_type)
      return Null if mime_type =~ /^image/
      CLASSES[mime_type] || Basic
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

    class Null < self
      def tokenize
        []
      end
    end

    class ApplicationRuby < self
      def tokenize
        Ripper.tokenize(content, path)
      end
    end

    CLASSES = {
      "application/ruby" => ApplicationRuby
    }

  end
end

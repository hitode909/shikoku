# -*- coding: utf-8 -*-
require 'digest/sha1'
require 'grit'
require 'ripper'

module Shikoku
  class Tokenizer
    attr_accessor :path, :content, :mime_type

    def self.new_from_path_and_mime_type(path, mime_type)
      class_for_mime_type(mime_type).new.tap{ |me|
        me.path = path
        me.mime_type = mime_type
      }
    end

    def self.new_from_content_and_mime_type(content, mime_type)
      class_for_mime_type(mime_type).new.tap{ |me|
        me.content = content
        me.mime_type = mime_type
        me.path = 'dummy'
      }
    end

    def self.class_for_mime_type(mime_type)
      CLASSES[mime_type] || Basic
    end

    # --- common methods ---
    def content
      @content ||= open(path).read
    end

    def tokenize
      []
    end

    def tokenize_as_string
      tokenize.map{ |token|
        token.content
      }
    end

    def is_valid
      tokenize_as_string.join("").chomp == content.chomp
    end

    # --- tokenizers ---

    class Basic < self
      def tokenize
        content.split(/\b|(\s+)/m).map{ |value|
          Shikoku::Token.new_from_content_and_token_class(value, '?')
        }
      end
    end

    class ApplicationRuby < self
      def tokenize
        Ripper.lex(content).map{ |tupple|
          position, token_class, token = *tupple
          Shikoku::Token.new_from_content_and_token_class(token, token_class)
        }
      end

    end

    class ApplicationPython < self
      def tokenize
        script_path = File.join File.dirname(__FILE__), 'python_tokenizer.py'
        list = JSON.parse `echo #{content} | python #{script_path}`
        list.map{ |tupple|
          token_class, token = *tupple
          Shikoku::Token.new_from_content_and_token_class(token, token_class)
        }
      end

    end

    class ApplicationPerl < self
      def tokenize
        return []
        # TODO...
        `echo  "#{content}" | perl -MPPI -l -e '$s=join(q{}, <STDIN>); for (@{PPI::Document->new(\\$s)->find(q{PPI::Token})}) { print $_ }'`.split(/\n+/)
      end
    end

    CLASSES = {
      "application/ruby" => ApplicationRuby,
      "application/python" => ApplicationPython,
      "application/perl" => ApplicationPerl,
    }

  end
end

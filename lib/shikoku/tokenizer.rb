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
      return @_tokenize_result if @_tokenize_result
      if self.respond_to? :_tokenize
        @_tokenize_result = self._tokenize
      else
        []
      end
    rescue => error
      warn error
      @is_valid = false
      []
    end

    def tokenize_as_string
      tokenize.map{ |token|
        token.content
      }
    end

    def is_valid
      tokenize if @is_valid.nil?

      if @is_valid.nil?
        @is_valid = tokenize_as_string.join("").chomp == content.chomp
      end

      @is_valid
    end

    # --- tokenizers ---

    class Basic < self
      def _tokenize
        content.split(/\b|(\s+)/m).map{ |value|
          Shikoku::Token.new_from_content_and_token_class(value, '?')
        }
      end
    end

    class ApplicationRuby < self
      def _tokenize
        Ripper.lex(content).map{ |tupple|
          position, token_class, token = *tupple
          Shikoku::Token.new_from_content_and_token_class(token, token_class)
        }
      end

    end

    class ApplicationPython < self
      def _tokenize
        script_path = File.join File.dirname(__FILE__), 'python_tokenizer.py'

        json_string = ""
        io = IO.popen("python #{script_path}", "r+")
        io.puts content
        io.close_write
        while line = io.gets do
          json_string += line
        end
        pid, exit_status = Process.waitpid2 io.pid
        raise "sub process died" if exit_status != 0
        list = JSON.parse json_string
        list = _fill_space(list)
        @is_valid = true
        list.map{ |tupple|
          token_class, token = *tupple
          Shikoku::Token.new_from_content_and_token_class(token, token_class)
        }
      end

      # 空白ずれていくのでここで調整………
      def _fill_space(list)
        builded = ""
        new_list = []
        puts content
        list.each{ |tupple|
          token_class, token = *tupple

          loop {
            expected = content[builded.length]

            if token.length == 0 || !expected || expected.length == 0 || builded.length == 0 || (builded + token) == content[0...(builded+token).length]
              break
            end
            new_list << ['padding', expected]
            builded += expected
          }
          new_list << tupple
          builded += token
        }
        new_list
      end
    end

    class ApplicationPerl < self
      def tokenize
        return []
        # TODO...
        `echo  "#{content}" | perl -MPPI -l -e '$s=join(q{}, <STDIN>); for (@{PPI::Document->new(\\$s)->find(q{PPI::Token})}) { print $_ }'`.split(/\n+/)
      rescue => error
        warn error
        []
      end
    end

    CLASSES = {
      "application/ruby" => ApplicationRuby,
      "application/python" => ApplicationPython,
      "application/perl" => ApplicationPerl,
    }

  end
end

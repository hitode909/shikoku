# -*- coding: utf-8 -*-

module Shikoku
  class Token
    attr_accessor :content, :token_class

    def self.new_from_content_and_token_class(content, token_class)
      self.new.tap{ |me|
          me.content = content.to_s
          me.token_class = token_class.to_s
        }
    end

    def is_separator?
      not self.content =~ /\S/
    end

    def to_s
      {
        :value => self.content,
        :class => self.token_class,
      }.to_s
    end

  end
end

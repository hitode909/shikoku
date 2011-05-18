# -*- coding: utf-8 -*-

self_file =
  if File.symlink?(__FILE__)
    require 'pathname'
    Pathname.new(__FILE__).realpath
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/../lib")

require 'bundler/setup'
require 'shikoku'
require 'pp'

repos = Shikoku::Repository.new_from_remote "git://github.com/hitode909/kindairb.git"
pp repos.files

# repository内のファイルもクラス作る必要ある，ファイルオブジェクトはtokenizer作ったり，更新日時を見てDBと同期したりとかする

file = repos.files[4]

t = Shikoku::Tokenizer.new_from_path(file)
pp t
p t.tokenize


file = repos.files.last

t = Shikoku::Tokenizer.new_from_path(file)
pp t
p t.tokenize

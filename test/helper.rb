# encoding: utf-8

require 'rubygems'
require 'minitest/unit'

MiniTest::Unit.autorun

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'lockdown'

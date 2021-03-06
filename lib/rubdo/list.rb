require 'time'
require 'yaml'
require 'fileutils'

module Rubdo
  class List
    attr_reader :items, :completed, :storage, :archive

    def initialize
      @storage = File.expand_path('~/.tasks/Todo.yml')
      @archive = File.expand_path('~/.tasks/Archive.yml')
      @items, @completed = [], []
      FileUtils.mkdir_p File.dirname @storage
      @items = load @storage
      @completed = load @archive
    end

    def add(description)
      @items << Item.new(description)
    end

    def write
      File.open(@storage, 'w') { |todos| todos.write(@items.select { |item| item.done == false }.to_yaml) }
      File.open(@archive, 'w') { |todos| todos.write(@completed.to_yaml) }
    end

    def load(file)
      return YAML.load_file(file) if File.exists? file
      []
    end

    def done(id)
      abort("that id doesn't exists") if @items[id].nil?
      @items[id].done = true
      @items[id].completed_at = Time.new
      @completed << @items[id]
    end

    def info(id)
      @items[id].to_s
    end

    alias_method :<<, :add
  end
end

require 'tempfile'

module Rubdo
  class CLI
    def initialize
      @list = List.new
      @id = ARGV[1].to_i - 1 
    end

    def add
      if ARGV[1]
        @list.add ARGV[1]
      else
        tmp_file = Tempfile.new('new_task')
        system("$EDITOR #{tmp_file.path}")
        unless File.read(tmp_file.path).empty?
          @list.add File.read(tmp_file).chomp  
          tmp_file.delete
        else
          puts "aborted due to empty file"
        end
      end
    end

    def done
      @list.done @id
    end

    def remove
      @list.remove @id
    end

    def save
      @list.write
    end

    def list
      @list.items.each_with_index { |item, index| puts "#{index + 1}: #{item.description}" }
      puts "no tasks" if @list.items.empty?
    end

    def info
      puts @list.info @id
    end

    def completed
      @list.completed.each { |item| puts "#{item.description}, completed at: #{item.completed_at.strftime('%m.%d.%y - %H:%M')}" }
    end

    def edit
      abort("not a valid id") if @id == -1 or @id > @list.items.length
      tmp_file = Tempfile.new('new_desc')
      File.open(tmp_file.path, 'w') { |f| f.write(@list.items[@id].description) }
      system("$EDITOR #{tmp_file.path}")
      @list.items[@id].description = File.read(tmp_file).chomp
      tmp_file.delete
    end

    def remove
      @list.items.delete_at @id
    end

    def help
      puts <<-HELP
Commands for rubdo:
------------------     
add/a [task description] - Add a new task. If the description is empty, $EDITOR is opened
list/ls - Lists all tasks
completed - List all completed tasks
done/d [task id] - Complete a task
info [task id] - Gives info about the specific task
edit/e [task id] - Opens up $EDITOR to edit the task description
remove/rm [task id] - Deletes the specific task
help - Prints out this information
      HELP
    end

    alias_method :ls, :list
    alias_method :rm, :remove
  end
end

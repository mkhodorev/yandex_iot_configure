module YandexIotConfigure
  class ProgressInfo
    def initialize(name:, count:)
      @count = count
      @name = name
      @completed = 0
      @sym = '-'
      print_info
    end

    def print_info
      print "\r#{@name}: [#{spinner}] Count: #{@count} | Сompleted: #{@completed}     "
    end

    def update
      @completed += 1
      print_info
    end

    def success
      puts "\n#{@name}: Success"
    end

    private

    def spinner
      @sym =  case @sym
              when '\\'
                '|'
              when '|'
                '/'
              when '/'
                '-'
              when '-'
                '\\'
              else
                '-'
              end
    end
  end
end

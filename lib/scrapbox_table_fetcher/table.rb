module ScrapboxTableFetcher
  class Table
    def initialize(name, column_names, content_rows)
      @name = name
      @column_names = column_names
      @table = []
      content_rows.map { |raw_row|
        row = {}
        raw_row.each_with_index {|item, index| row[column_names[index]] = item}
        @table << row
      }
    end

    attr_reader :name, :column_names, :table

    def search_row(column_name, key)
      @table.select{|row| row[column_name] == key}
    end

    def get_column(column_name)
      @table.map{|row| row[column_name]}
    end

    def random_row
      @table.sample
    end

  end
end

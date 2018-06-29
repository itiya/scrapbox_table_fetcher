require "scrapbox"

module ScrapboxTableFetcher
  class Fetcher

    def initialize(name)
      @name = name
    end

    def fetch(page_title)
      @scrapbox ||= Scrapbox::Project.new(@name)
      page = Scrapbox::Page.new(@scrapbox, page_title)

      get_raw_table_array(page.text).map { |raw_table|
        if raw_table.length >= 3 # テーブル名の行、列名の行、内容の行で少なくとも3行以上が必要
          clean_raw_table = raw_table.map {|line| line.lstrip.chomp}
          name = clean_raw_table.shift.match(TABLE_TOP_REGEXP)[:name]
          table_contents = clean_raw_table.map { |line| line.split("\t") }
          column_names = table_contents.shift

          table_contents.inject(true){ |result, row| result && row.length == column_names.length } ?
              ScrapboxTableFetcher::Table.new(name, column_names, table_contents) : nil
        else
          nil
        end
      }.compact
    end

    private

    TABLE_TOP_REGEXP = /\s*table:(?<name>[^\n]+)/

    def table_top_line?(line)
      TABLE_TOP_REGEXP.match(line)
    end

    def indent_count(line)
      /(?<indent>[ \t\r\f]*)[^\n]*/.match(line)[:indent].length
    end

    def table_end?(line, table_indent_count)
      indent_count(line) != table_indent_count + 1
    end

    def get_raw_table_array(raw_text)
      in_table = false
      table_indent_count = nil
      raw_table_array = []
      raw_table = nil

      raw_text.lines do |line|
        if in_table
          if table_end?(line, table_indent_count)
            in_table = false
            raw_table_array << raw_table
          else
            raw_table << line
          end
        else
          if table_top_line?(line)
            in_table = true
            table_indent_count = indent_count(line)
            raw_table = []
            raw_table << line
          end
        end
      end

      if in_table
        raw_table_array << raw_table
      end
      raw_table_array
    end
  end
end

require "scrapbox"
require "scrapbox_table_fetcher/version"

module ScrapboxTableFetcher
  class Fetcher

    def initialize(name)
      @name = name
    end

    def fetch(page_title)
      @scrapbox ||= Scrapbox::Project.new(@name)
      page = Scrapbox::Page.new(@scrapbox, page_title)
      page.text.lines {|line| p line}
    end
  end
end

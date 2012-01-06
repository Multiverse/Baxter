require 'rubygems'
require 'cinch'
require 'cgi'
require 'open-uri'
require 'nokogiri'
require 'parseconfig'

$config = ParseConfig.new('credentials.cfg')
$urlhelpers = Hash["c" => "Core", "p" => "Portals", "n" => "NetherPortals", "s" => "SignPortals", "a" => "Adventure"]
$authrequired = true

require './handlers.rb'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.esper.net"
    c.nick = "MV-Baxter"
    c.user = $config.get_value('username')
    c.password = $config.get_value('password')
    c.channels = ARGV

    c.plugins.plugins = [WikiLink]
  end
  
  helpers do
    # https://github.com/Multiverse/Multiverse-Core/issues/354
    def issue(section, issue)
      actualsection = $urlhelpers[section]
      url = "https://github.com/Multiverse/Multiverse-#{actualsection}/issues/#{CGI.escape(issue)}"
      begin
        doc = Nokogiri::HTML(open(url))
      rescue OpenURI::HTTPError
        return "Sorry, issue ##{issue} didn't exist on #{actualsection}!"
      end
      return url
    end

    def wiki(sections, search)
      actualresults = []
      sections.each do |section|
        actualsection = $urlhelpers[section]
        url = "https://github.com/Multiverse/Multiverse-#{actualsection}/wiki/_pages"
        doc = Nokogiri::HTML(open(url))
        if doc == nil
          return "Couldn't find the #{actualsection} wiki!!!"
        end
        things = doc.xpath("//div[@id='template']//ul//li//a")
        pagelist = things.map{|link| [link.children.text, link['href']]}
        pagelist.each do |result|
          if(result[0].downcase.include?(CGI.escape(search)))
            actualresults<<"http://github.com" + result[1]
          end
        end
      end
      if actualresults.count > 3
        return actualresults[0, 5]<<"..."
      elsif actualresults.count == 0
        return ["No results found :("]
      end
      return actualresults
    end
    
    def latest(plugins)
      if plugins == nil
        plugins = ["c", "p", "n", "s", "a"]
      end
      results = ""
      plugins.each do |plugin|
        actual = $urlhelpers[plugin]
        url = "http://ci.onarandombox.com/job/Multiverse-#{actual}/lastSuccessfulBuild/"
        doc = Nokogiri::HTML(open(url))
        results<<"#{actual} " + doc.xpath("//h1").first.text.strip.gsub(/\s+\(.*\)/, ", ")
      end
      return results[0..-3]
    end
  end
end

bot.start

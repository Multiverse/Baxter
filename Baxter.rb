require 'rubygems'
require 'cinch'
require 'cgi'
require 'open-uri'
require 'nokogiri'
require 'parseconfig'
$config = ParseConfig.new('credentials.cfg')
$urlhelpers = Hash["c" => "Core", "p" => "Portals", "n" => "NetherPortals", "s" => "SignPortals", "a" => "Adventure"]
$authrequired = true
bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.esper.net"
    c.nick = "MV-Baxter"
    c.user = $config.get_value('username')
    c.password = $config.get_value('password')
    c.channels = ARGV
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
  # TODO: Move these to a file
  on :message, /^wiki$/i do |m|
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "https://github.com/Multiverse/Multiverse-Core/wiki/"
    end
  end
  
  on :message, /^ci$/i do |m|
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "http://ci.onarandombox.com/job/Multiverse-Core"
    end
  end
  
  on :message, /^forum$/i do |m|
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "http://forums.bukkit.org/threads/3707/page-9999"
    end
  end
  
  on :message, /^latest$/i do |m|
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply(latest(nil))
    end
  end
  
  on :message, "fish" do |m|
    if m.user.authname == "fernferret"
      m.reply "Hello master Fern..."
      bot.logger.debug m.user
    end
  end
  
  on :message, /(hello|hi|greetings)\s*baxter/i do |m|
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      greetings = ["Hello", "Bonjour", "Hi", "Aloha", "Sup"]
      m.reply(greetings[rand(greetings.size)] + " #{m.user.nick}!")
    end
  end
  
  on :message, "help" do |m|
    m.user.send("Hi, My name is Baxter and I'm a super helpful bot.")
    m.user.send("I'm here to help, but I'm currently being abused.")
    m.user.send("Only OPs and VOICEs in #multiverse can abuse me for now :(")
    m.user.send("(Please send help!)")
  end
  
  on :message, /!issue-?([cpnsa])\s?#(\d+)/i do |m, type, issue|
    if m.user.authname == "mbaxter"
      m.reply "Hi mbaxter!"
      if m.channel.opped?(m.user)
        m.reply(issue(type,issue))
      end
    end
    if m.user.authname == "fernferret"
      m.reply "Hello master Fern..."
      m.reply(issue(type, issue))
    elsif m.channel.opped?(m.user)
      m.reply "Hello cool person #{m.user.nick}!"
      m.reply(issue(type, issue))
    elsif m.channel.voiced?(m.user)
      m.reply "Hello super person #{m.user.nick}!"
      m.reply(issue(type, issue))
    end
  end
  
  on :message, /!wiki-?([cpnsa])\s?:(.+)/i do |m, type, page|
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      wikiresults = wiki([type], page)
      wikiresults.each do |result|
        m.reply(result)
      end
    end
  end
  
  on :message, /!wiki\s?:(.+)/i do |m, page|
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      wikiresults = wiki(["c", "p", "n", "s"], page)
      wikiresults.each do |result|
        m.reply(result)
      end
    end
  end
end

bot.start


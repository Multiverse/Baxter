require 'rubygems'
require 'cinch'
require 'cgi'
require 'open-uri'
require 'nokogiri'
require 'parseconfig'
require 'octokit'
$config = ParseConfig.new('credentials.cfg')
$urlhelpers = Hash["c"    => "Core",  "p"       => "Portals", "n"             => "NetherPortals", "s"           => "SignPortals", "a"         => "Adventure",
                   "core" => "Core",  "portals" => "Portals", "netherportals" => "NetherPortals", "signportals" => "SignPortals", "adventure" => "Adventure"]
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
    def get_repo(abrev)
      return $urlhelpers[abrev.downcase]
    end
    
    def issue(section, issue)
      begin
        return Octokit.issue("Multiverse/Multiverse-#{get_repo(section)}", CGI.escape(issue)).html_url
      rescue Octokit::NotFound
        return "Sorry, issue ##{issue} didn't exist on #{get_repo(section)}!"
      end
    end
    
    def open_issues(section, milestone)
      open_issues = 0
      closed_issues = 0
      if milestone != nil and milestone.length > 0
        milestones = Octokit.milestones("Multiverse/Multiverse-#{get_repo(section)}").map{|mile| [mile.title, mile.number]}
        matches = []
        matchnames = []
        milestones.each do |ms|
          if ms[0].downcase.include?(milestone.downcase)
            matches<<ms[1]
            matchnames<<ms[0]
          end
        end
        
        # Now go get all of those milestones
        matches.each do |match|
          open_issues += Octokit.issues("Multiverse/Multiverse-#{get_repo(section)}", {:milestone => match}).count
          closed_issues += Octokit.issues("Multiverse/Multiverse-#{get_repo(section)}", {:milestone => match, :state => "closed"}).count
        end
        return "There are #{open_issues} open and #{closed_issues} in #{get_repo(section)} for Milestone(s) #{matchnames}."
      else
        open_issues += Octokit.issues("Multiverse/Multiverse-#{get_repo(section)}").count
        closed_issues += Octokit.issues("Multiverse/Multiverse-#{get_repo(section)}", {:state => "closed"}).count
        return "There are #{open_issues} open and #{closed_issues} in #{get_repo(section)}."
      end
      
    end
    
    def commit(hash)
      $urlhelpers.each_value do |section|
        url = "https://github.com/Multiverse/Multiverse-#{section}/commit/#{CGI.escape(hash)}"
        begin
          doc = Nokogiri::HTML(open(url))
          return url
        rescue OpenURI::HTTPError
          # Keep trying
        end
      end
      return nil
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
      m.reply "http://ci.onarandombox.com/view/Multiverse"
    end
  end
  
  on :message, /^jd$/i do |m|
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
  
  on :message, /^issues\s*([^\s]*)?\s*([^\s]*)?$/i do |m, section, mile|
    
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply(open_issues(section, mile))
    end
  end
  
  on :message, /\b([0-9a-f]{5,40})\b/ do |m, hash|
    # Ensure we're not in a loop.
    if m.user.authname == $config.get_value('username')
      return
    end
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      url = commit(hash)
      if url
        m.reply(url)
      end
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
    m.user.send("I'm here to help, but I'm currently being developed.")
    m.user.send("Only OPs and VOICEs in #multiverse can use me for now!")
  end
  
  on :message, /!issue-?([cpnsa])\s?#(\d+)/i do |m, type, issue|
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


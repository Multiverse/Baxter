class CoreWiki
  include Cinch::Plugin

  match /wiki$/

  def execute(m)
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "https://github.com/Multiverse/Multiverse-Core/wiki/"
    end
  end
end

class CI
  include Cinch::Plugin

  match /ci$/

  def execute(m)
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "http://ci.onarandombox.com/job/Multiverse-Core"
    end
  end
end

class Forum
  include Cinch::Plugin

  match /forum$/

  def execute(m)
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "http://forums.bukkit.org/threads/3707/page-9999"
    end
  end
end

class Latest
  include Cinch::Plugin

  match /latest$/i

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

  def execute(m)
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply(self.latest(nil))
    end
  end
end

class Greetings
  include Cinch::Plugin

  match /(hello|hi|greetings)\s*baxter/i

  def execute(m)
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      greetings = ["Hello", "Bonjour", "Hi", "Aloha", "Sup"]
      m.reply(greetings[rand(greetings.size)] + " #{m.user.nick}!")
    end
  end
end
  
class Help
  include Cinch::Plugin

  match "help"

  def execute(m)
    m.user.send("Hi, My name is Baxter and I'm a super helpful bot.")
    m.user.send("I'm here to help, but I'm currently being developed.")
    m.user.send("Only OPs and VOICEs in #multiverse can use me for now!")
  end
end

class Issue
  include Cinch::Plugin

  match /issue-?([cpnsa])\s?#(\d+)/i

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

  def execute(m, type, issue)
    if m.user.authname == "fernferret"
      m.reply "Hello master Fern..."
      m.reply(self.issue(type, issue))
    elsif m.channel.opped?(m.user)
      m.reply "Hello cool person #{m.user.nick}!"
      m.reply(self.issue(type, issue))
    elsif m.channel.voiced?(m.user)
      m.reply "Hello super person #{m.user.nick}!"
      m.reply(self.issue(type, issue))
    end
  end
end

class Wiki
  include Cinch::Plugin

  match /wiki(?:-?([cpnsa]))?\s?:(.+)/i

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

  def execute(m, type, page)
    self.bot.logger.debug type
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      type = (type.nil? && ["c", "p", "n", "s"]) || [type]
      wikiresults = wiki(type, page)
      wikiresults.each do |result|
        m.reply(result)
      end
    end
  end
end

class WikiLink
  include Cinch::Plugin

  match "wiki"

  def execute(m)
    bot.logger.debug "Someone said wiki"
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "https://github.com/Multiverse/Multiverse-Core/wiki/"
    end
  end
end

#  on :message, /^ci$/i do |m|
#    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
#      m.reply "http://ci.onarandombox.com/job/Multiverse-Core"
#    end
#  end
#  
#  on :message, /^forum$/i do |m|
#    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
#      m.reply "http://forums.bukkit.org/threads/3707/page-9999"
#    end
#  end
#  
#  on :message, /^latest$/i do |m|
#    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
#      m.reply(latest(nil))
#    end
#  end
#  
#  on :message, "fish" do |m|
#    if m.user.authname == "fernferret"
#      m.reply "Hello master Fern..."
#      bot.logger.debug m.user
#    end
#  end
#  
#  on :message, /(hello|hi|greetings)\s*baxter/i do |m|
#    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
#      greetings = ["Hello", "Bonjour", "Hi", "Aloha", "Sup"]
#      m.reply(greetings[rand(greetings.size)] + " #{m.user.nick}!")
#    end
#  end
#  
#  on :message, "help" do |m|
#    m.user.send("Hi, My name is Baxter and I'm a super helpful bot.")
#    m.user.send("I'm here to help, but I'm currently being developed.")
#    m.user.send("Only OPs and VOICEs in #multiverse can use me for now!")
#  end
#  
#  on :message, /!issue-?([cpnsa])\s?#(\d+)/i do |m, type, issue|
#    if m.user.authname == "fernferret"
#      m.reply "Hello master Fern..."
#      m.reply(issue(type, issue))
#    elsif m.channel.opped?(m.user)
#      m.reply "Hello cool person #{m.user.nick}!"
#      m.reply(issue(type, issue))
#    elsif m.channel.voiced?(m.user)
#      m.reply "Hello super person #{m.user.nick}!"
#      m.reply(issue(type, issue))
#    end
#  end
#  
#  on :message, /!wiki-?([cpnsa])\s?:(.+)/i do |m, type, page|
#    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
#      wikiresults = wiki([type], page)
#      wikiresults.each do |result|
#        m.reply(result)
#      end
#    end
#  end
#  
#  on :message, /!wiki\s?:(.+)/i do |m, page|
#    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
#      wikiresults = wiki(["c", "p", "n", "s"], page)
#      wikiresults.each do |result|
#        m.reply(result)
#      end
#    end
#  end

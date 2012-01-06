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
      m.reply(self.issue(type, issue))
    elsif m.channel.voiced?(m.user)
      m.reply(self.issue(type, issue))
    end
  end
end

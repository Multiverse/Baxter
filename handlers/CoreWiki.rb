class CoreWiki
  include Cinch::Plugin

  match /wiki$/

  def execute(m)
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "https://github.com/Multiverse/Multiverse-Core/wiki/"
    end
  end
end

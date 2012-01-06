class Forum
  include Cinch::Plugin

  match /forum$/

  def execute(m)
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "http://forums.bukkit.org/threads/3707/page-9999"
    end
  end
end

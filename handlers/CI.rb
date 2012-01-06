class CI
  include Cinch::Plugin

  match /ci$/

  def execute(m)
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      m.reply "http://ci.onarandombox.com/job/Multiverse-Core"
    end
  end
end

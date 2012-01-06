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

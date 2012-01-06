class Help
  include Cinch::Plugin

  match "help"

  def execute(m)
    m.user.send("Hi, My name is Baxter and I'm a super helpful bot.")
    m.user.send("I'm here to help, but I'm currently being developed.")
    m.user.send("Only OPs and VOICEs in #multiverse can use me for now!")
  end
end

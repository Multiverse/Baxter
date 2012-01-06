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

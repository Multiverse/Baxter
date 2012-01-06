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
        return ["Couldn't find the #{actualsection} wiki!!!"]
      end
      things = doc.xpath("//div[@id='wiki-content']//ul//li//a")
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
    type = (type.nil? && ["c", "p", "n", "s"]) || [type]
    self.bot.logger.debug type
    if m.channel.opped?(m.user) || m.channel.voiced?(m.user)
      wikiresults = self.wiki(type, page)
      wikiresults.each do |result|
        m.reply(result)
      end
    end
  end
end

require 'rubygems'
require 'cinch'
require 'cgi'
require 'open-uri'
require 'nokogiri'
require 'parseconfig'

$config = ParseConfig.new('credentials.cfg')
$urlhelpers = Hash["c" => "Core", "p" => "Portals", "n" => "NetherPortals", "s" => "SignPortals", "a" => "Adventure"]
$authrequired = true

require './handlers.rb'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.esper.net"
    c.nick = "MV-Baxter"
    c.user = $config.get_value('username')
    c.password = $config.get_value('password')
    c.channels = ARGV

    c.plugins.plugins = [CoreWiki, CI, Forum, Latest, Greetings, Help, Issue, Wiki]
  end
  
  helpers do
    # https://github.com/Multiverse/Multiverse-Core/issues/354

    
  end
end

bot.start

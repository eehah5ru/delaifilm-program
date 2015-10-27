require "open-uri"
require 'nokogiri'
require 'active_support/all'

module FilmHash
  def self.mk_hash (obj)
    obj.to_s.gsub(/[^a-zа-яA-ZА-Я]/, '')[1..10].mb_chars.downcase.to_s.hash    
  end
end
  
Film  = Struct.new(:name, :url) do
  def film_hash
    FilmHash.mk_hash(self.name)
  end
end

class FilmCatalog
  DEFAULT_FILM_URL = "http://delaifilm.ru/!!!!!!"

  def self.instance
    @film_catalog = FilmCatalogBuilder.new.build if @film_catalog.nil?

    return @film_catalog
  end

  
  def initialize
    @catalog = {}
  end

  def add (film)
    @catalog[film.film_hash] = film
  end

  def get (an_id)
    h = FilmHash.mk_hash(an_id)

    unless @catalog.key?(h)
      STDERR.puts "FILM NOT FOUND: #{an_id}"
      return default_film
    end
    
    return @catalog[h]
  end

  def default_film
    return Film.new("!!!!!!!!!!!!", DEFAULT_FILM_URL)
  end

  def films
    return @catalog
  end
end

class FilmCatalogBuilder
  FILMS_SOURCE = "http://delaifilm.ru/2015/films/"

  
  def initialize
    
  end

  def build
    result = FilmCatalog.new
    
    @doc = Nokogiri::XML(html)
    @doc.css("div.movie-item h2 a").each do |f|
      result.add(Film.new(f.text, f['href']))
    end

    debug_catalog result
    
    return result
  end

  def html
    @html = fetch_html if @html.nil?

    STDERR.puts @html
    
    return @html
  end

  private

  def fetch_html
    open(FILMS_SOURCE) do |f|
      f.read
    end
  end

  def debug_catalog (catalog)
    STDERR.puts "DEBUGGING FILMS CATALOG"
    STDERR.puts "CATALOG SIZE: #{catalog.films.length}"
    catalog.films.each do |h, i|
      STDERR.puts "#{i.name} - #{i.url}"
    end
  end
end


module Helpers
  INTEREST_DEFENCE_ICON = "template/images/pic1.png"

  ENVIRRONMENT_ICON = "template/images/pic2.png"

  ART_ACIVISM_ICON = "template/images/pic3.png"

  OTHERS_ICON = "template/images/pic4.png"
  
  def icon (type=:empty)
    return td_icon{ "&nbsp;" } if type == :empty

    return td_icon{ icon_img INTEREST_DEFENCE_ICON } if type == :interests_defence

    return td_icon{ icon_img ENVIRRONMENT_ICON }  if type == :environment

    return td_icon{ icon_img ART_ACIVISM_ICON } if type == :art_activism

    return td_icon{ icon_img OTHERS_ICON } if type == :others

    return td_icon{ "!!!!!!!!!!!!!!!!!!" }
  end

  def empty_time
    td_time{ "&nbsp;" }
  end

  
  def event_time start, stop
    td_time{ "#{start}&nbsp;&mdash;&nbsp;#{stop}" }
  end

  def link_to_film (name)
    return "<a href='#{FilmCatalog.instance.get(name).url}'>#{name}</a>"
  end

  
  private

  def td_time &block
    return "<td class='time'>#{ block.call }</td>"    
  end
  
  def td_icon &block
    return "<td class='icon'>#{block.call}</td>"
  end
  
  def icon_img pic_url
    return "<img src='#{pic_url}' alt=''></img>"
  end


end

load "fast_gem.rb"

FastGem.load "curb"
FastGem.load "json"

require 'tempfile'

if false
  
TEST_URLS = <<-TXT
http://3columns.net/habitual/docs/images/ruby.png
http://www.weilichskann.de/wp-content/uploads/2008/10/ruby.jpg
http://therevelationpainting.files.wordpress.com/2009/10/ruby.jpg
http://my.opera.com/azad123/homes/blog/1Ruby-055.jpg
http://www.mnh.si.edu/exhibits/images/ruby/carmen_lucia_ruby_front.jpg
http://www.gemaffair.com/images/RUBY_FANCY_SQUARE.jpg
http://www.palagems.com/Images/ruby_thai_1pt21cts.jpg
http://library.thinkquest.org/08aug/01930/graphics/pagegraphics/chromium_ruby.jpg
http://tastinggod.files.wordpress.com/2009/09/vv-ruby1.jpg
http://www.3dnews.ru/documents/7351/RUBY_Standing_2.jpg
http://ati.amd.com/designpartners/media/images/wp/Ruby_Return_1024.jpg
http://astroyogisays.files.wordpress.com/2009/06/ruby.jpg
http://www.knowtebook.com/uploaded/2008/05/ruby-vs-php.jpg
http://migo.sixbit.org/papers/Introduction_to_Ruby/ruby-diamond-ring-8.gif
http://migo.sixbit.org/papers/Introduction_to_Ruby/ruby-diamond-ring-7.gif
http://shakatak66.files.wordpress.com/2009/10/ruby-tuesday-2.jpg
http://jewelry-blog.internetstones.com/wp-content/uploads/2008/03/rosser-reeves-star-ruby-sri-lanka-gemstone.jpg
http://mcadams.posc.mu.edu/ruby3.jpg
http://www.ruby-sapphire.com/images/photo_cd_images/1373-31.jpg
http://aussiesapphire.files.wordpress.com/2006/07/ruby.jpg
http://www.jewelinfo4u.com/images/Gallery/madagascar_ruby.jpg
TXT

end


module Imaging; end

require "imaging/identify"
require "imaging/tag"

module Imaging
  #
  # Identify a single URL
  module Base
    def identify(*urls)
      Identify.new(*urls)
    end
  end
  
  extend Base
  
  #
  # Caching
  module Cache
    SLICE = 16
    
    module HashCache
      def get(key)
        fetch(key)
      rescue IndexError
      end

      def set(key, value)
        update key => value
      end
    end

    class DummyCache
      def self.get(key); end
      def self.set(key, value); end
    end
    
    def cache=(cache)
      if cache.is_a?(Hash)
        cache.extend HashCache
      end
      @cache = cache
    end

    def cache
      @cache || DummyCache
    end

    def identify(*urls)
      results = {}
      
      missed_urls = urls.reject do |url|
        if r = cache.get(url)
          results[url] = r
        end
      end

      missed_urls.each_slice(SLICE) do |slice|
        super(*slice).each do |url,r|
          cache.set(url, r)
          results.update url => r
        end
      end
      
      results
    end
  end
  
  extend Cache

  #
  # Testcase
  # def self.tag(*args)
  #   self.cache = {}
  #   
  #   STDERR.puts Tag.new("http://www.lshift.net/img/lshiftLogo50.png", :width => 12)
  #   STDERR.puts Tag.new("http://www.lshift.net/img/lshiftLogo50.png", :width => 12, :fill => true)
  # 
  #   STDERR.puts Tag.new("http://www.lshift.net/img/lshiftLogo50.png", :width => 12, :height => 12, :fill => true)
  #   STDERR.puts Tag.new("http://www.lshift.net/img/lshiftLogo50.png", :width => 12, :height => 12)
  # 
  #   STDERR.puts Tag.new("http://www.lshift.net/img/lshiftLogo50.png", :width => 12, :fill => true)
  #   STDERR.puts Tag.new("http://www.lshift.net/img/lshiftLogo50.png", :width => 12)
  # 
  #   STDERR.puts Tag.new("http://www.lshift.net/img/lshiftLogo50.png", :width => 120, :height => 12)
  #   STDERR.puts Tag.new("http://www.lshift.net/img/lshiftLogo50.png", :width => 120, :height => 12, :fill => true)
  # end

  def self.tag(url, opts)
    Tag.new(url, opts)
  end
    
  def self.exec(*args)
    if defined?(TEST_URLS)
      args = TEST_URLS.split("\n") 
    end
    
    return unless r = Identify.new(*args)
    if args.length == 1
      r.values.first 
    else
      r.to_json
    end
  end
end

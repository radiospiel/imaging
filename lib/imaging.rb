load "fast_gem.rb"

FastGem.load "curb"
FastGem.load "json"

require 'tempfile'

if true
  
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

module Imaging
  def self.exec(*args)
    if defined?(TEST_URLS)
      args = TEST_URLS.split("\n") 
    end
    
    return unless r = Identify::run(*args)
    if args.length == 1
      r = r.values.first 
      puts r
    else
      puts r.to_json
    end
  end
end

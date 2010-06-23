require "cgi"

class Imaging::Tag < String

  #
  # Create an image tag for an image of a given URL, to match exactly
  # the requested target size.
  #
  # Options are:
  #
  #   :width => width in pixels
  #   :height => height in pixels
  #   :fill => when set, fill the entire area; defaults to false
  #
  def initialize(url, opts)
    opts = opts.dup

    width = opts.delete(:width)
    height = opts.delete(:height)
    fill = opts.delete(:fill)

    image_width, image_height = *identify_to_width_and_height(url)
    
    if width || height
      tw, th = image_width, image_height

      #
      # At which ratio we will show the image? This is the maximum 
      # requested if fill is set, and the minimum requested otherwise. 
      # This calculates the "width" and "height" parameters for the 
      # resulting image tag.
      r1, r2 = width && 1.0 * width / tw, height && 1.0 * height / th
      if !r1 || !r2
        ratio = r1 || r2
      elsif r1 < r2 
        ratio = fill ? r2 : r1
      else
        ratio = fill ? r1 : r2
      end

      #
      # This is the final image size
      opts.update :width => (tw * ratio + 0.5).to_i, :height => (th * ratio + 0.5).to_i
    end

    #
    # add margin
    pw = width ? width - opts[:width] : 0
    ph = height ? height - opts[:height] : 0

    if ph == 0 && pw == 0
      0
    elsif ph.even? && pw.even?
      opts.update(:style => "margin: #{ph/2}px #{pw/2}px")
    else
      opts.update(:style => "margin: #{ph/2}px #{pw/2}px #{ph - ph/2}px #{pw - pw/2}px")
    end

    #
    # create image tag
    itag = tag :img, opts.update(:src => url)
    
    if pw < 0 || ph < 0
      itag = tag(:div, itag, :style => "width: #{size[:width]}px; height: #{size[:height]}px; overflow: hidden")
    end

    super itag
  end
  
  private
  
  def identify_to_width_and_height(url)
    width_x_height = Imaging.identify(url).values.first
    if width_x_height =~ /(\d+)x(\d+)/
      return [ $1.to_i, $2.to_i ]
    end
  end
  
  def tag(name, *args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    
    content = args.join("\n")
    
    head = opts.inject([name]) do |arr, (k,v)|
      arr << "#{k}='#{CGI::escapeHTML(v.to_s)}'"
    end.join(" ")

    if content.empty?
      "<#{head} />"
    else
      "<#{head}>#{content}</#{name}>"
    end
  end
end

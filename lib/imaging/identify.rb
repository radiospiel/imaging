class Imaging::Identify < Hash

  def initialize(*urls)
    #
    # build Curl::Multi object
    
    multi = Curl::Multi.new
    multi.pipeline = true
    multi.max_connects = 10
    
    urls.each do |url|
      c = Curl::Easy.new(url) do |curl|
        curl.follow_location = true
        curl.on_body  { |data| image_file(url).write(data) }
      end
      multi.add(c)
    end

    #
    # download all files into temporary locations
    multi.perform

    #
    # identify all temporary files
    args, path_to_url = [], {}
    image_files.each do |url, file|
      path_to_url[file.path] = url
      args << file.path
    end
    
    image_files.values.each(&:close)
    
    return nil if args.empty?
      
    %x(identify #{args.join(" ")}).split("\n").each do |line|
      file, kind, size = *line.split(/\s+/)
      file.sub!(/\[[0-9]+\]$/, "")
      
      update path_to_url[file] => size
    end
  ensure
    image_files.each do |_,file|
      file.close
    end
    
    @image_files = nil
  end

  private
  
  def image_files
    @image_files ||= {}
  end
  
  def image_file(url)
    image_files[url] ||= Tempfile.new("img")
  end
end

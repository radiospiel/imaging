class Imaging::Identify < Hash

  def initialize(*urls)
    files, real_urls = urls.partition do |url|
      (url =~ /^(http|https):\/\//).nil?
    end
    
    identify_urls(real_urls)
    identify_files(files)
  end

  def curl_multi(urls)
    #
    # build Curl::Multi object
    multi = Curl::Multi.new
    multi.pipeline = true
    multi.max_connects = 10
    
    urls.each do |url|
      c = Curl::Easy.new(url) do |curl|
        curl.follow_location = true
        curl.on_body  { |data| temp_file(url).write(data) }
      end
      multi.add(c)
    end
    
    multi
  end

  def identify_files(files)
    return if files.empty?
    
    %x(identify #{files.join(" ")}).
      split("\n").
      each do |line|
        file, kind, size = *line.split(/\s+/)
        file.sub!(/\[[0-9]+\]$/, "")

        next if self[file]
        self[file] = size

        yield file, size if block_given?
      end
  end
  
  def identify_urls(urls)
    @temp_files = {}
    
    #
    # download all files into temporary locations
    curl_multi(urls).perform
    close_temp_files

    #
    # identify all temporary files
    path_to_url = {}
    @temp_files.each do |url, file|
      path_to_url[file.path] = url
    end

    identify_files(path_to_url.keys) do |file, size|
      update path_to_url[file] => size
    end
  ensure
    close_temp_files
    @temp_files = nil
  end

  def close_temp_files
    return unless @temp_files
    @temp_files.values.each(&:close)
  end
  
  def temp_file(url)
    @temp_files[url] ||= Tempfile.new("img")
  end
  #     private
  # 
  # def image_files
  #   @image_files ||= {}
  # end
  # 
  # def image_file(url)
  #   image_files[url] ||= Tempfile.new("img")
  # end
end

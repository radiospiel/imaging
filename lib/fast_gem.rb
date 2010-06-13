module Gem
  require 'rbconfig'

  ConfigMap = {
    :EXEEXT            => RbConfig::CONFIG["EXEEXT"],
    :RUBY_SO_NAME      => RbConfig::CONFIG["RUBY_SO_NAME"],
    :arch              => RbConfig::CONFIG["arch"],
    :bindir            => RbConfig::CONFIG["bindir"],
    :datadir           => RbConfig::CONFIG["datadir"],
    :libdir            => RbConfig::CONFIG["libdir"],
    :ruby_install_name => RbConfig::CONFIG["ruby_install_name"],
    :ruby_version      => RbConfig::CONFIG["ruby_version"],
    :rubylibprefix     => RbConfig::CONFIG["rubylibprefix"],
    :sitedir           => RbConfig::CONFIG["sitedir"],
    :sitelibdir        => RbConfig::CONFIG["sitelibdir"],
    :vendordir         => RbConfig::CONFIG["vendordir"] ,
    :vendorlibdir      => RbConfig::CONFIG["vendorlibdir"]
  }
  
  def self.user_home
    ENV["HOME"]
  end
end

require 'rubygems/defaults'

module FastGem
  (class << self; self; end).class_eval do
    def paths
      [ "#{Gem.default_dir}/gems", "#{Gem.user_dir}/gems" ]
    end

    def best(files, offset = 0)
      files.
        compact.
        sort_by { |file| file[offset..-1] }.
        last
    end
    
    def find(name)
      best paths.map { |path|
        ofs = "#{path}/#{name}-*"
        best Dir.glob("#{ofs}*"), ofs.length }
    end
    
    def load(name)
      path = find(name)
      # STDERR.puts "Load #{name} from #{path}"
      $: << "#{path}/lib"
      require name
    end
  end
end

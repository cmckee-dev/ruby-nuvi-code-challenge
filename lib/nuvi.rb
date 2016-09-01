require "nuvi/version"

require 'nokogiri'
require 'net/http'
require 'open-uri'
# require 'redis'
require 'logger'
require 'zip'
# require 'fileutils'
require 'pry'

module Nuvi
  class Web
  # Your code goes here...
    # Start refactoring code into modules and nuvi.rb
    def initialize
    end

    def start(url)
    end
  end

  class DownloadZip
    attr_accessor :url, :directory

    def initialize(url)
      @url = url
      @directory = File.join(Dir.pwd, '.tmp', 'zips')

      # Make tmp directory for downloads if one isnt already created
      FileUtils.mkdir_p(directory) unless Dir.exists?(directory)
      # TODO: Better logging implimentation needed
      @logger = Logger.new STDOUT
    end

    def get_list
      rls ||= Nokogiri::HTML(open(url).read).css('td a')[1..-1].map { |a| url + a[:href] }
    end

    def download(zip_uri)
      uri = URI(zip_uri)
      destination = File.join(directory, File.basename(uri.path))

      if File.exists?(destination)
        @logger.info("Duplicate, Skipping the download of #{zip_uri}.")
      else
        @logger.info("Downloading #{zip_uri} to #{destination}.")

        temp_file = "#{destination}"
        # Caveat here:
        # First implimentation was http.get(uri), but doesnt return full response allowing to ready body
        # binding.pry
        http = Net::HTTP.start(uri.host, uri.port)
        # binding.pry
        # Working implimentation here:
        http.request(Net::HTTP::Get.new(uri)) do |response|
          # By default Net::HTTP reads an entire response into memory.
          # If you are handling large files or wish to implement a progress bar you can instead stream the body directly to an IO.
          open destination, 'w' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
      end
      IO.copy_stream(temp_file, destination)
      end
      destination
    end
  end
  # binding.pry

  class Unzip
    attr_accessor :directory
    def initalize
      @logger = Logger.new STDOUT
      self.directory = File.join(Dir.pwd, '.tmp', 'xmls')
    end
    def unzip(file)
      destination = File.join(directory, Files.basename(file, '.zip'))
      FileUtils.rm_rf(destination)
      FileUtils.mkdir_p(destination)
      @logger.info("Unzipping #{file} to #{destination}")

      Zip::File.open do |zip_file|
        zip_file.each do |file_name|
          file_name.extract(File.join(destination, file_name)) unless File.exsist?
        end
      end
    end
  end

  class RedisStore
  end
end

# files = Nuvi::DownloadZip.new("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/")
# binding.pry
# files.get_list.each { |zip| files.download(zip) }

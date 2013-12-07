require 'stringio'
require 'zlib'

module Clickstream
  class Compressor

    def self.encoding_handled?(content_encoding)
      %w(gzip deflate).include? content_encoding
    end

    def self.unzip(source, content_encoding)
      case content_encoding
        when 'gzip' then decompress(source)
        when 'deflate' then inflate(source)
        else source
      end
    end

    def self.zip(source, accept_encoding)
      if accept_encoding.match 'deflate'
        deflate(source)
      elsif  accept_encoding.match 'gzip'
        compress(source)
      else
        source
      end
    end

    # Compresses a string using gzip inspired by ActiveSupport::Gzip
    def self.compress(source)
      output = StringIO.new
      gz = Zlib::GzipWriter.new(output)
      gz.write(source)
      gz.close
      output.string
    end

    def self.deflate(source)
      Zlib::Deflate.deflate(source)
    end

    def self.decompress(source)
      Zlib::GzipReader.new(StringIO.new(source)).read
    end

    def self.inflate(source)
      Zlib::Inflate.inflate(source.read)
    end

  end
end
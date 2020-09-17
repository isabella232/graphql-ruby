# frozen_string_literal: true

require 'digest/sha2'

module GraphQL
  module Language
    class Cache
      def initialize(path)
        @path = path
      end

      def fetch(filename)
        hash = Digest::SHA256.new << GraphQL::VERSION << filename
        begin
          hash << File.mtime(filename).to_i.to_s
        rescue SystemCallError
          return yield
        end
        cache_path = @path.join(hash.to_s)

        if cache_path.exist?
          Marshal.load(cache_path.read)
        else
          payload = yield
          tmp_path = "#{cache_path}.#{rand}"
          File.binwrite(tmp_path, Marshal.dump(payload))
          File.rename(tmp_path, cache_path.to_s)
          payload
        end
      end
    end
  end
end

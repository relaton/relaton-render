require "concurrent"
require "net/http"
require "uri"

module Relaton
  module Render
    class General
      def url_exist?(url_string)
        return true # temporarily disabling validation of URIs
        url = URI.parse(url_string)
        url.host or return true # allow file URLs
        res = access_url(url) or return false
        res.is_a?(Net::HTTPRedirection) and return url_exist?(res["location"])
        res.code[0] != "4"
      rescue Errno::ENOENT, SocketError
        false # false if can't find the server
      end

      def access_url(url)
        path = url.path or return false
        path.empty? and path = "/"
        url_head(url, path)
      rescue StandardError => e
        warn e
        false
      end

      def url_head(url, path)
        ret = nil
        @semaphore.synchronize { ret = @urlcache[url.to_s] }
        ret and return ret
        ret = Net::HTTP.start(url.host, url.port,
                              read_timeout: 2, open_timeout: 2,
                              use_ssl: url.scheme == "https") do |http|
          http.request_head(path)
        end
        @semaphore.synchronize { @urlcache[url.to_s] = ret }
        ret
      end

      def urls_exist_concurrent(urls)
        responses = Concurrent::Array.new
        thread_pool = Concurrent::FixedThreadPool.new(5)
        urls.each do |u|
          thread_pool.post { responses << url_exist_async?(u) }
        end
        thread_pool.shutdown
        thread_pool.wait_for_termination
        responses.each_with_object({}) { |n, m| m[n[:url]] = n[:status] }
      end

      def url_exist_async?(url_string)
        { url: url_string, status: url_exist?(url_string) }
      end
    end
  end
end

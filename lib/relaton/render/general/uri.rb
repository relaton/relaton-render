require "concurrent"
require "net/http"
require "uri"
require "net_http_timeout_errors"

module Relaton
  module Render
    class General
      OK_CODES = [
        Net::HTTPOK,
        Net::HTTPCreated,
        Net::HTTPNonAuthoritativeInformation,
        Net::HTTPPartialContent,
        Net::HTTPMultipleChoices,
        Net::HTTPNotModified,
      ].freeze

      NON_ACCESSIBLE_CODES = [
        Net::HTTPNotFound,
        Net::HTTPGone,
      ].freeze

      # could happen but does not mean a url is accessible or not
      UNKNOWN_STATE_CODES = [
        Net::HTTPEarlyHints, # 103
        Net::HTTPMovedPermanently, # 301
        Net::HTTPFound, # 302
        Net::HTTPSeeOther, # 303
        Net::HTTPUseProxy, # 305
        Net::HTTPTemporaryRedirect, # 307
        Net::HTTPPermanentRedirect, # 308
        Net::HTTPUnauthorized, # 401
        Net::HTTPPaymentRequired, # 402
        Net::HTTPForbidden, # 403
        Net::HTTPMethodNotAllowed, # 405
        Net::HTTPNotAcceptable, # 406
        Net::HTTPProxyAuthenticationRequired, # 407
        Net::HTTPRequestTimeOut, # 408
        Net::HTTPConflict, # 409
        Net::HTTPPreconditionFailed, # 412
        Net::HTTPRequestEntityTooLarge, # 413
        Net::HTTPRequestURITooLong, # 414
        Net::HTTPUnsupportedMediaType, # 415
        Net::HTTPExpectationFailed, # 417
        Net::HTTPMisdirectedRequest, # 421
        Net::HTTPUnprocessableEntity, # 422
        # 425
        Net::HTTPUpgradeRequired, # 426
        Net::HTTPTooManyRequests, # 429
        Net::HTTPRequestHeaderFieldsTooLarge, # 431
        Net::HTTPUnavailableForLegalReasons, # 451
        Net::HTTPInternalServerError, # 500
        Net::HTTPNotImplemented, # 501
        Net::HTTPBadGateway, # 502
        Net::HTTPServiceUnavailable, # 503
        Net::HTTPGatewayTimeOut, # 504
        Net::HTTPVersionNotSupported, # 505
        Net::HTTPVariantAlsoNegotiates, # 506
        Net::HTTPNetworkAuthenticationRequired, # 511
        # 520-527 cloudflare
        # 530
      ].freeze

      ACCESSIBLE = :accessible
      NON_ACCESSIBLE = :non_accessible
      POSSIBLY_ACCESSIBLE = :possibly_accessible
      UNEXPECTED_RESPONSE = :unexpected_response

      def url_is_not_accessible?(url)
        state = url_state(url)
        case state
        when NON_ACCESSIBLE
          true
        when ACCESSIBLE, POSSIBLY_ACCESSIBLE, UNEXPECTED_RESPONSE
          false
        else
          raise "Unknown state '#{state}' for URL '#{url}'"
        end
      end

      # Returns 4 types of result:
      # (1) ACCESSIBLE - definetely accessible
      # (2) NON_ACCESSIBLE - definetely not
      # (3) POSSIBLY_ACCESSIBLE - possibly accessible
      # (4) UNEXPECTED_RESPONSE - unexpected response, for all other cases
      def url_state(url_string)
        url = URI.parse(url_string)
        url.is_a?(URI::File) and return ACCESSIBLE
        url.path or return NON_ACCESSIBLE # does not allow broken URLs

        # when could not connect, it could be temporary
        res = access_url(url) or return POSSIBLY_ACCESSIBLE

        case res
        when *NON_ACCESSIBLE_CODES then NON_ACCESSIBLE
        when *OK_CODES then ACCESSIBLE
        when *UNKNOWN_STATE_CODES then POSSIBLY_ACCESSIBLE
        else UNEXPECTED_RESPONSE # TODO: track somewhere an unexpected code
        end
      rescue URI::InvalidURIError
        NON_ACCESSIBLE
      end

      def access_url(url)
        tries ||= 0

        path = url.path.empty? ? "/" : url.path

        NetHttpTimeoutErrors.conflate do
          url_head(url, path)
        end
      rescue NetHttpTimeoutError => e
        tries += 1
        retry if tries < 3

        warn e
        nil
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
          thread_pool.post do
            responses << url_exist_async?(u)
          rescue StandardError => e
            warn "Error in a thread pool: #{e.inspect}. " \
              "Backtrace:\n#{e.backtrace.join("\n")}"
          end
        end
        thread_pool.shutdown
        thread_pool.wait_for_termination
        responses.each_with_object({}) { |n, m| m[n[:url]] = n[:status] }
      end

      def url_exist_async?(url_string)
        { url: url_string, status: !url_is_not_accessible?(url_string) }
      end
    end
  end
end

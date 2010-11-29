require "savon/soap/xml"
require "savon/soap/fault"
require "savon/http/error"

module Savon
  module SOAP

    # = Savon::SOAP::Response
    #
    # Represents the SOAP response and contains the HTTP response.
    class Response

      # Expects an <tt>HTTPI::Response</tt> and handles errors.
      def initialize(response)
        self.http = response
        raise_errors if Savon.raise_errors?
      end

      attr_accessor :http

      # Returns whether the request was successful.
      def success?
        !soap_fault? && !http_error?
      end

      # Returns whether there was a SOAP fault.
      def soap_fault?
        soap_fault.present?
      end

      # Returns the <tt>Savon::SOAP::Fault</tt>.
      def soap_fault
        @soap_fault ||= Fault.new http
      end

      # Returns whether there was an HTTP error.
      def http_error?
        http_error.present?
      end

      # Returns the <tt>Savon::HTTP::Error</tt>.
      def http_error
        @http_error ||= HTTP::Error.new http
      end

      # Returns the SOAP response body as a Hash.
      def to_hash
        @hash ||= Savon::SOAP::XML.to_hash to_xml
      end

      # Traverses the SOAP response Hash for a given +path+ of Hash keys
      # and returns the value as an Array. Defaults to return an empty Array
      # in case the path does not exist or returns nil.
      def to_array(*path)
        value = path.inject to_hash do |memo, key|
          return [] unless memo[key]
          memo[key]
        end
        
        value.kind_of?(Array) ? value.compact : [value].compact
      end

      # Returns the SOAP response XML.
      def to_xml
        http.body
      end

    private

      def raise_errors
        raise soap_fault if soap_fault?
        raise http_error if http_error?
      end

    end
  end
end

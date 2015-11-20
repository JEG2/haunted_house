require "openssl"
require "open-uri"
require "rexml/document"

require "haunted_house/device"

class HauntedHouse
  def initialize(address, user, password)
    @address  = address
    @user     = user
    @password = password
    @devices  = [ ]

    lookup_devices
  end

  def request(url)
    open( "#{@address}/rest/#{url}",
          :http_basic_authentication => [@user, @password],
          :ssl_verify_mode           => OpenSSL::SSL::VERIFY_NONE ) do |data|
      yield data if block_given?
    end
  end

  def device(name)
    @devices.find { |device| device.name == name }
  end

  private

  def lookup_devices
    request("nodes") do |data|
      xml = REXML::Document.new(data)
      xml.elements.each("nodes/node") do |node|
        if (name    = node.elements["name"].text    rescue nil) and
           (address = node.elements["address"].text rescue nil)
          @devices << Device.new(self, name, address)
        end
      end
    end
  end
end

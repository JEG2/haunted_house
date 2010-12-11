require "openssl"
require "open-uri"
require "rexml/document"

require "haunted_house/device"

# FIXME: this is dangerous
OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

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
          :http_basic_authentication => [@user, @password] ) do |data|
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

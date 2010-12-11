require "erb"

class Device
  def initialize(service, name, address)
    @service = service
    @name    = name
    @address = address
  end
  
  attr_reader :name
  
  def fast_on
    send_command("DFON")
  end
  
  def fast_off
    send_command("DFOF")
  end
  
  private
  
  def send_command(command)
    @service.request("nodes/#{ERB::Util.u @address}/cmd/#{command}")
  end
end

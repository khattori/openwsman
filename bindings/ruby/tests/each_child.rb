# win32_services.rb
#  enumerate/pull/release for Win32_Service
#
# Coded after wsmancli/examples/win32_service.c
#
#

require 'test/unit'
require 'rexml/document'
require '../src/rwsman'
require '_client'

class WsmanTest < Test::Unit::TestCase
  def test_client
    client = Client.open
    assert client
    options = WsMan::ClientOption.new
    assert options
#    options.flags = WsMan::CLIENTOPTION_DUMP_REQUEST
#    puts "Flags = #{options.flags}"

#
# see http://msdn2.microsoft.com/en-us/library/aa386179.aspx for a list of CIM classes
#   the Win32 classes are derived from
#
#    uri = "http://schemas.microsoft.com/wbem/wsman/1/wmi/root/cimv2/Win32_Service"
    uri = "http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ComputerSystem"
    result = client.enumerate( uri, options )
    assert result

    results = 0
    faults = 0
    context = nil
 
#loop do
    context = result.context
    raise "No context inside result" unless context
#    puts "Context #{context} retrieved"

    result = client.pull( uri, context, options )
    break unless result

    results += 1
    body = result.body
    fault = body.child( 0, WsMan::NS_SOAP, "Fault" )
    if fault
	puts "Got fault"
	faults += 1
	break
    end

    node = body.PullResponse.Items.child

    node.each_child { |child|
	text = child.text
	acount = child.attr_count
	puts "Child [#{acount}] #{child.name}: #{text}"
	if acount > 0
	    child.each_attr{ |attr| puts "\tAttr #{attr.ns}:#{attr.name}=#{attr.value}" }
	end
#	return false if text.nil?
    }
    name = node.Name
    state = node.State

    puts "#{name} is #{state}"
#end

    client.release( uri, context, options ) if context
    puts "Context released, #{results} results, #{faults} faults"
  end
end

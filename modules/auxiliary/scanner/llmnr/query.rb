##
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Auxiliary
  include Msf::Auxiliary::Report
  include Msf::Auxiliary::UDPScanner
  include Msf::Auxiliary::LLMNR

  def initialize(info = {})
    super(
      update_info(
        info,
        'Name'           => 'LLMNR Query',
        'Description'    => %q(
        ),
        'Author'         =>
          [
            'Jon Hart <jon_hart[at]rapid7.com>'
          ],
        'License'        => MSF_LICENSE
      )
    )
  end

  def build_probe
    @probe ||= ::Net::DNS::Packet.new(datastore['NAME'], query_type_num, query_class_num).data
  end

  def scanner_process(data, shost, _sport)
    @results[shost] ||= []
    @results[shost] << data
  end

  def scanner_prescan(batch)
    print_status("Sending LLMNR #{query_type_name} #{query_class_name} queries to #{batch[0]}->#{batch[-1]} (#{batch.length} hosts)")
    @results = {}
  end

  def scanner_postscan(_batch)
    @results.each_pair do |peer, resps|
      resps.each do |resp|
        print_good("#{peer} responded with #{Resolv::DNS::Message.decode(resp).inspect}")
      end
    end
  end
end

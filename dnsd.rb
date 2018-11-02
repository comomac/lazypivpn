#!/usr/bin/env ruby

#
# Local dns server
# 
# Prevent DNS leak
# Allow query local machine and vpn provider only
#

Dir.chdir('/var')

require 'process/daemon'
require 'process/daemon/privileges'

require 'rubydns'
require 'envbash'

EnvBash.load('/usr/local/lib/lazypivpn/ipnet.sh')


INTERFACES = [
	[:udp, '0.0.0.0', 53]
]

# run as user
RUN_AS = 'daemon'

# final dns use
# use local dns to allow query local machine hostname and vpn provider
DNS_SERVER_INT = ENV['dns_int']
# query external dns behind vpn
DNS_SERVER_EXT = ENV['dns_ext']
# vpn gateway server domain that will be queried directly without vpn
str = ENV['vpn_dns_regex']
raise "vpn_dns_regex is blank!" unless str and str.length > 5 # sanity check, making sure no blank or bad input
VPN_DNS_REGEX = /^#{str}$/

if Process::Daemon::Privileges.current_user != 'root'
	$stderr.puts 'Sorry, this command needs to be run as root!'
	exit 1
end

# A DNS server that selectively drops queries based on the requested domain
# name.  Queries for domains that match specified regular expresssions
# (like 'microsoft.com' or 'sco.com') return NXDomain, while all other
# queries are passed to upstream resolvers.
class RubyDNSServer < Process::Daemon
	Name = Resolv::DNS::Name
	IN = Resolv::DNS::Resource::IN

	def startup
		RubyDNS.run_server(listen: INTERFACES) do
			on(:start) do
				Process::Daemon::Privileges.change_user(RUN_AS)

				if ARGV.include?('--debug')
					@logger.level = Logger::DEBUG
					$stderr.sync = true
				else
					@logger.level = Logger::WARN
				end
			end

			upstream_int = RubyDNS::Resolver.new([[:udp, DNS_SERVER_INT, 53], [:tcp, DNS_SERVER_INT, 53]])
			upstream_ext = RubyDNS::Resolver.new([[:udp, DNS_SERVER_EXT, 53], [:tcp, DNS_SERVER_EXT, 53]])

			# resolve local network name with local dns
			match(/^[a-z0-9\-]+$/, IN::A) do |transaction|
				logger.info 'Local LAN host'
				transaction.passthrough!(upstream_int)
			end

			# # resolve vpn provider name with local dns
			# pia_regex_orig = /\.privateinternetaccess\.com$/
			# pia_regex = /^(aus-melbourne|aus|brazil|ca|ca-toronto|denmark|fi|france|germany|hk|in|ireland|israel|italy|japan|mexico|nl|nz|no|ro|sg|kr|sweden|swiss|turkey|uk-london|uk-southampton|us-california|us-chicago|us-east|us-florida|us-midwest|us-newyorkcity|us-seattle|us-siliconvalley|us-texas|us-west)\.privateinternetaccess\.com$/
			# match(pia_regex, IN::A) do |transaction|
			# 	logger.info 'PIA VPN domain'
			# 	transaction.passthrough!(upstream_int)
			# end

			# resolve vpn provider name with local dns
			match(VPN_DNS_REGEX, IN::A) do |transaction|
				logger.info 'VPN Gateway Server domain'
				transaction.passthrough!(upstream_int)
			end

			# Default DNS handler
			# resolve everything else
			otherwise do |transaction|
				logger.info 'Passing DNS request upstream...'
				transaction.passthrough!(upstream_ext)
			end
		end
	end
end

RubyDNSServer.daemonize
require "china_ad_ip/version"
require 'china_ad_ip/ipv4'
require 'csv'

module ChinaAdIp
  NAME            = "ChinaAdIp"
  GEM             = "china_ad_ip"
  AUTHORS         = ["suezhen <sz3001@gmail.com>"]


  def self.ntoa(uint)
    unless(uint.is_a? Numeric and uint <= 0xffffffff and uint >= 0)
        raise(::ArgumentError, "not a long integer: #{uint.inspect}")
    end
    ret = []
    4.times do 
        ret.unshift(uint & 0xff)
        uint >> 8
    end
    ret.join('.')
  end

  def ipv4?
    self.kind_of? ChinaAdIp::IPv4
  end

  def self.valid?(addr)
    valid_ipv4?(addr)
  end

  def self.valid_ipv4?(addr)
    if /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/ =~ addr
      return $~.captures.all? {|i| i.to_i < 256}
    end
    false
  end

  def self.ip_file(path)
    unless FileTest::exist?(path)
      raise(::ArgumentError, "not exists: #{path}")
    else
      if $ip_sections.nil?
        $ip_sections = CSV.read(path) 
        $ip_sections.reject!{|ip_section| ChinaAdIp::IPv4.new(ip_section[0]).to_i==0 }.map! { |ip_section|  [ChinaAdIp::IPv4.new(ip_section[0]).to_i,ChinaAdIp::IPv4.new(ip_section[1]).to_i,ip_section[2],ip_section[3]]  }
      end
    end
  end


  def self.location_file(path)
    unless FileTest::exist?(path)
      raise(::ArgumentError, "not exists: #{path}")
    else
      if $locations.nil?
        $locations = CSV.read(path,:encoding=>"utf-8") 
        $locations = Hash[$locations.map {|location| id = location.shift; [id,location << !!id.match(/^1156/)] }]
      end
    end
  end


  def self.locate(addr)

    ip_addr = ChinaAdIp::IPv4.new(addr)

    if $ip_sections && $locations

      index = dichotomy(ip_addr.to_i,$ip_sections.collect{|ip_section| ip_section[0]}.to_a) 

      $locations[$ip_sections[index][2]]
    else
      raise(::ArgumentError, "not exists csv data")    
    end

  end


  def self.dichotomy(search,array)
    index = 0 , start_index = 0 , end_index = array.length
    while(true)
      index = start_index + ((end_index - start_index) / 2)
      start_index = index if array[index] < search
      end_index = index if array[index] > search
      break if array[index] == search || ((start_index == index) && (start_index+1 == end_index))
    end 
    index
  end


end

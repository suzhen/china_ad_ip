require "china_ad_ip/version"
require 'china_ad_ip/ipv4'
require 'csv'
require 'ffi'

module ChinaAdIp
  NAME            = "ChinaAdIp"
  GEM             = "china_ad_ip"
  AUTHORS         = ["suezhen <sz3001@gmail.com>"]

  extend FFI::Library
  ffi_lib File.join(File.expand_path("../",__FILE__), "libbinarysearch.so") 
  attach_function :binarysearch, [:pointer,:long,:long], :long

  module LibC
      extend FFI::Library
      ffi_lib FFI::Library::LIBC

      # memory allocators
      attach_function :malloc, [:size_t], :pointer
      attach_function :calloc, [:size_t], :pointer
      attach_function :valloc, [:size_t], :pointer
      attach_function :realloc, [:pointer, :size_t], :pointer
      attach_function :free, [:pointer], :void

      # memory movers
      attach_function :memcpy, [:pointer, :pointer, :size_t], :pointer
      attach_function :bcopy, [:pointer, :pointer, :size_t], :void

  end # module LibC

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
      index =  ChinaAdIp.binarysearch(self.arr_pointer,ip_addr.to_i,ip_arr.length)
      $locations[$ip_sections[index][2]]
    else
      raise(::ArgumentError, "not exists csv data")    
    end

  end


  def self.ip_arr
    @@ip_arr ||= $ip_sections.collect{|ip_section| ip_section[0]}.to_a
  end

  def self.arr_pointer
    buffer = LibC.malloc(ip_arr.first.size * ip_arr.size)
    buffer.write_array_of_long ip_arr
  end

end

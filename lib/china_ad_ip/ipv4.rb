module ChinaAdIp

  class IPv4

    include ChinaAdIp

    REGEXP = Regexp.new(/((25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)/)


    def initialize(str)
      ip, netmask = str.split("/")
      
      # Check the ip and remove white space
      if ChinaAdIp.valid_ipv4?(ip)
        @address = ip.strip
      else
        raise ArgumentError, "Invalid IP #{ip.inspect}"
      end
      
      # Array formed with the IP octets
      @octets = @address.split(".").map{|i| i.to_i}
      # 32 bits interger containing the address
      @u32 = (@octets[0]<< 24) + (@octets[1]<< 16) + (@octets[2]<< 8) + (@octets[3])
      
    end # def initialize


    def address
      @address
    end

    def octets
      @octets
    end

    def to_s
      @address
    end

    def u32
      @u32
    end
    alias_method :to_i, :u32
    alias_method :to_u32, :u32


    def self.extract(str)
      self.new REGEXP.match(str).to_s
    end


  end

end
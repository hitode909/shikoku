module Shikoku
  module Utility
    class << self
      def system_or_die(command, *args)
        puts [command, args].flatten.join(" ")
        system([command, args].flatten.join(" ")) or raise "#{command} returned #{$?}"
      end
    end
  end
end




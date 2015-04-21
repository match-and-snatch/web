module Extensions
  module String
    def possessive
      if self.end_with?("'s")
        self.dup
      else
        self + ('s' == self[-1,1] ? "'" : "'s")
      end
    end
  end
end

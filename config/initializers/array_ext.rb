class Array; def mean; self.sum/self.size.to_f; end; end
class Array; def variance; mean = self.mean; Math.sqrt(inject( nil ) { |var,x| var ? var+((x-mean)**2) : ((x-mean)**2)}/self.size.to_f); end; end

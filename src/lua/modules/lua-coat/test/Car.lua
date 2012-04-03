
require 'Coat.Role'

role 'Breakable'

has.is_broken = { is = 'rw', isa = 'boolean' }

function method:_break ()
    self.is_broken = true
    return "I broke"
end

singleton 'Car'
with 'Breakable'

has.engine = { is = 'ro', isa = 'Engine' }


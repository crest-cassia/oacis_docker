require 'erb'

module Xsub

  module Template
    def self.render( template, variables )
      b = binding
      variables.each do |name, value|
        b.eval("#{name} = #{value.inspect}")
        # b.local_variable_set(name.to_sym, value)
      end
      ERB.new(template).result(b)
    end
  end
end

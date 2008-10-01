require 'node.rb'

module Structurograme
  # Simple class that extends _Array_ for holding other elements in 
  # _Structurograme_. This acts as _Node_.
  class Holder < Array
    include Node

    alias old_push push  
    # Add a node to holder. Also assign _self_ as parent to _node_ if it 
    # supports it.
    def push(node)
      node.parent = self if node.respond_to? 'parent'
      old_push(node)
    end

    # Render all nodes that we're holding and return end coordinates: [x, y].
    def render_at(x, y, fake_run=false)
      each do |node|
        x, y = node.render_at(x, y, fake_run)
      end
      [x, y]
    end
  end
end
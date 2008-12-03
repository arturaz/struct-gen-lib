$LOAD_PATH.push File.dirname(__FILE__)
require 'node.rb'

class Structurograme
  # Simple class that extends _Array_ for holding other elements in 
  # _Structurograme_. This acts as _Node_.
  class Holder < Array
    include Node

    # Add a node to holder. Also assign _self_ as parent to _node_ if it 
    # supports it.
    def push(node)
      node.parent = self if node.respond_to? :parent
      super(node)
    end
    
    # Calculate node heigth
    def height; map(&:height).sum; end

    # Render all nodes that we're holding and return end coordinates: [x, y].
    def render_at(x, y)
      each do |node|
        node.render_at(x, y)
        y += node.height
      end
      true
    end
  end
end
class LibXML::XML::Node
  # Iterate through children but skip child if it's name is in _args_.
  def each_without(*args)
    # Turn everything into string
    args.map!(&:to_s)
    
    each do |child|
      next if args.include? child.name
      yield child
    end
  end
end
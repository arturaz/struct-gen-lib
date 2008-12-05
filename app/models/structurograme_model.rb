STRUCTUROGRAME_DIR = File.join(RAILS_ROOT, 'vendor', 'structurograme')
require File.join(STRUCTUROGRAME_DIR, 'lib', 'structurograme.rb')
require 'pathname'

# Simple Rails like model class that wraps Structurograme
class StructurogrameModel
  FONT = Pathname.new(File.join(STRUCTUROGRAME_DIR, "cour.ttf"))
  
  attr_reader :errors, :params
  
  def size; params[:size]; end
  def size=(value); params[:size] = value; end
  def width; params[:width]; end
  def width=(value); params[:width] = value; end
  def xml; params[:xml]; end
  def xml=(value); params[:xml] = value; end
  
  def initialize(params={})    
    @params = {:size => 12, :width => 800}.merge((params || {}).symbolize_keys)
    @errors = []
  end
  
  # Is this model valid?
  def valid?
    # Clear out errors
    @errors = []
    
    errors.push "Tuščias XML. Gal įrašytum ką nors?..." if params[:xml].blank?
    errors.push "Padidink šriftą" if params[:size].to_i <= 0
    errors.push "Padidink paveiksliuko plotį" if params[:width].to_i <= 0    
    return false unless errors.blank?
    
    @document = XML::Parser.string(self.class.normalize_xml(params[:xml])).parse    
    true
  rescue LibXML::XML::Error => e
    errors.push "Klaida parsinant XML: #{e.message}"
    false
  end
  
  # Rescue from common user errors.
  def self.normalize_xml(xml)
    # Ensure we have root node
    if %r{^(<\?xml.*?\?>)?\s*<(s|struct|structurograme)>.*?</\2>\s*$}m.match(
      xml
    ).nil?
      xml = "<s>#{xml}</s>"
    end
    # Replace strange chars that XML parser might choke on.
    xml.gsub('&', '&amp;').gsub('\<', '&lt;').gsub('\>', '&gt;').gsub('\"', '&quot;')      
  end
  
  # Return PNG as a string with our structurograme
  def render
    return unless valid?
    Structurograme.new(@document.root, FONT, params[:size].to_i, 
      params[:width].to_i).render
  end
end
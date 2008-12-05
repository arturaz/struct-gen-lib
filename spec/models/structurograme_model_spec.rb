require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StructurogrameModel do
  describe "object" do
    before(:each) do
      @model = StructurogrameModel.new(:size => 12, :width => 800, 
        :xml => "<block>TEST</block>")
    end

    it "should be valid" do
      @model.should be_valid
    end

    it "should not be valid with malformed xml" do
      @model.xml = "<block>asdasdad<block>"
      @model.should_not be_valid
    end

    it "should add error with malformed xml" do
      @model.xml = "<block>asdasdad<block>"
      @model.valid?
      @model.errors.should_not be_blank
    end

    [:size, :width].each do |attr|
      it "should not be valid with invalid #{attr}" do
        @model.send("#{attr}=", 0)
        @model.should_not be_valid
      end

      it "should add error with invalid #{attr}" do
        @model.send("#{attr}=", 0)
        @model.valid?
        @model.errors.should_not be_blank
      end

      it "should have default #{attr}" do
        model = StructurogrameModel.new
        model.send(attr).should_not be_nil
      end
    end

    describe "#render" do
      it "should return nil if struct is invalid" do
        @model.stub!(:valid?).and_return(false)
        @model.render.should be_nil
      end

      it "should return PNG otherwise" do
        @model.render[1..3].should eql("PNG")
      end
    end
  end
  
  describe "class" do
    describe ".normalize_xml" do
      it "should add root node if absent" do
        xml = "<block>TEST</block>"
        StructurogrameModel.normalize_xml(xml).should_not eql(xml)
      end
    end
  end
end

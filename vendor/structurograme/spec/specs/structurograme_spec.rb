require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

TEST_DATA =<<EOF
<s>
 <block>Hello</block>
 <block></block>
 <call>I am your friend</call>
 <if clause="Are we friendly?">
  <true>
   <block>Hurray!</block>
  </true>
  <false width="80">
   <while clause="While we're unfriendly">
    <block>&lt;Friendlyness++&gt;</block>
   </while>
  </false>
 </if>
 <if clause="true ratio">
  <true width="80">
   <block>true ratio</block>
  </true>
  <false>
   <block>true ratio</block>
  </false>
 </if>
 <if clause="no ratio">
  <true>
   <block>No ratio</block>
  </true>
  <false>
   <block>No ratio</block>
  </false>
 </if>
 <if clause="no false">
  <true>
   <block>No false</block>
  </true>
 </if>
 <if clause="no true">
  <false>
   <block>No true</block>
  </false>
 </if>
</s>
EOF

def parse(data)
  XML::Parser.string(data).parse
end

describe Structurograme do
  describe "#render" do
    it "should return PNG" do
      model = Structurograme.new(parse(TEST_DATA).root, FONT)
      model.render[1..3].should eql("PNG")
    end
    
    it "should not fail if image is disproportional" do
      lambda do
        Structurograme.new(parse(TEST_DATA).root, FONT, 48, 100).render
      end.should_not raise_error
    end
  end
end

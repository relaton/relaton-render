# encoding: utf-8

require "spec_helper"

RSpec.describe Iso690Render do
  it "has a version number" do
    expect(Iso690Render::VERSION).not_to be nil
  end

  it "render incollection" do
    input = <<~INPUT
      <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <date type="published"><on>2005</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <surname>Ramsey</surname>
              <initial>J. K.</initial>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <surname>McGrew</surname>
              <initial>W. C.</initial>
            </name>
          </person>
        </contributor>
        <relation type="includedIn">
          <bibitem>
            <title>The nature of play: Great apes and humans</title>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Pellegrini</surname>
                  <initial>A. D.</initial>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <initial>P. K.</initial>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Guilford Press</name>
              </organization>
            </contributor>
            <place>New York, NY</place>
          </bibitem>
        </relation>
        <extent type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
        </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. and MCGREW, W. C.. Object play in great apes: Studies in nature and captivity. In: PELLEGRINI, A. D. and SMITH, P. K., <I>The nature of play: Great apes and humans</I>. New York, NY, 2005. pp. 89&ndash;112.</formattedref>
    OUTPUT
    template = <<~TEMPLATE
      {{ creatornames }} ({{date}}) |. <em>{{ title }}</em> [{{medium}}] ,_{{ edition }}_edition |.
      {{ standardidentifier | first }}. {{ uri }}. At:_{{ access_location }}.
    TEMPLATE
    p = Iso690Render
      .new(template: { incollection: template },
           nametemplate: { one: "{{surname[0] | upcase }}, {{initials[0]}}",
                           two: "{{surname[0] | upcase}}, {{initials[0]}} & {{initials[1]}} {{surname[1] | upcase}}" },
           lang: "en")
    expect(p.render(input))
      .to be_equivalent_to output
  end
end

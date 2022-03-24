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
              <initials>J. K.</initials>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <surname>McGrew</surname>
              <initials>W. C.</initials>
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
                  <initials>A. D.</initials>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <initials>P. K.</initials>
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
      {{ standardidentifier }}. {{ uri }}. At:_{{ access_location }}.
    TEMPLATE
    p = Iso690Parse
      .new(template: { incollection: template },
           nametemplate: ["{{surname}}, {{given}}",
                          "{{surname}}, {{given}} & {{given2}} {{surname}}"],
           lang: "en")
    expect(p.render(input))
      .to be_equivalent_to output
  end
end

# encoding: utf-8

require "spec_helper"

RSpec.describe Relaton::Render do
  it "renders incollection, two authors, with Arabic internationalisation" do
    input = <<~INPUT
      <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2019-09-03</on></date>
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
                  <forename>Anthony</forename>
                  <forename>D.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <forename>Peter</forename>
                  <forename>K.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Guilford Press</name>
              </organization>
            </contributor>
            <edition>3</edition>
            <medium>
              <form>electronic resource</form>
              <size>8vo</size>
            </medium>
            <place>New York, NY</place>
          </bibitem>
        </relation>
        <extent>
         <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
          </locality>
        </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. و W. C. MCGREW. Object play in great apes: Studies in nature and captivity. في: PELLEGRINI, Anthony D. و Peter K. SMITH (محرران): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. ؜الطبعة؜ ٣.؜؜. New York, NY: Guilford Press. 2005. ؜89–112 ص؜. [ينظر: 3 سبتمبر 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "ar")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with German internationalisation" do
    input = <<~INPUT
      <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2019-09-03</on></date>
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
                  <forename>Anthony</forename>
                  <forename>D.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <forename>Peter</forename>
                  <forename>K.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Guilford Press</name>
              </organization>
            </contributor>
            <edition>3</edition>
            <medium>
              <form>electronic resource</form>
              <size>8vo</size>
            </medium>
            <place>New York, NY</place>
          </bibitem>
        </relation>
        <extent>
          <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
          </locality>
        </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. und W. C. MCGREW. Object play in great apes: Studies in nature and captivity. In: PELLEGRINI, Anthony D. und Peter K. SMITH (Hrsg.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3 Aufl. New York, NY: Guilford Press. 2005. S. 89–112. [angesehen: 3. September 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "de")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Spanish internationalisation" do
    input = <<~INPUT
      <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2019-09-03</on></date>
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
                  <forename>Anthony</forename>
                  <forename>D.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <forename>Peter</forename>
                  <forename>K.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Guilford Press</name>
              </organization>
            </contributor>
            <edition>3</edition>
            <medium>
              <form>electronic resource</form>
              <size>8vo</size>
            </medium>
            <place>New York, NY</place>
          </bibitem>
        </relation>
                <extent>
          <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
          </locality>
        </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. y W. C. MCGREW. Object play in great apes: Studies in nature and captivity. En: PELLEGRINI, Anthony D. y Peter K. SMITH (eds.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3.ª ed. New York, NY: Guilford Press. 2005. págs. 89–112. [visto: 3 de septiembre de 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "es")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with French internationalisation" do
    input = <<~INPUT
      <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2019-09-03</on></date>
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
                  <forename>Anthony</forename>
                  <forename>D.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <forename>Peter</forename>
                  <forename>K.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Guilford Press</name>
              </organization>
            </contributor>
            <edition>3</edition>
            <medium>
              <form>electronic resource</form>
              <size>8vo</size>
            </medium>
            <place>New York, NY</place>
          </bibitem>
        </relation>
                <extent>
          <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
          </locality>
        </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. et W. C. MCGREW. Object play in great apes: Studies in nature and captivity. Dans: PELLEGRINI, Anthony D. et Peter K. SMITH (éd.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3e édition. New York, NY: Guilford Press. 2005. p. 89–112. [vu: 3 septembre 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "fr")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Russian internationalisation" do
    input = <<~INPUT
      <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2019-09-03</on></date>
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
                  <forename>Anthony</forename>
                  <forename>D.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <forename>Peter</forename>
                  <forename>K.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Guilford Press</name>
              </organization>
            </contributor>
            <edition>3</edition>
            <medium>
              <form>electronic resource</form>
              <size>8vo</size>
            </medium>
            <place>New York, NY</place>
          </bibitem>
        </relation>
                <extent>
          <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
          </locality>
        </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. и W. C. MCGREW. Object play in great apes: Studies in nature and captivity. в: PELLEGRINI, Anthony D. и Peter K. SMITH (изд.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. Третье издание. New York, NY: Guilford Press. 2005. стр. 89–112. [просмотрено: 3 сентября 2019 г.].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "ru")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Chinese internationalisation" do
    input = <<~INPUT
      <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2019-09-03</on></date>
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
                  <forename>Anthony</forename>
                  <forename>D.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <forename>Peter</forename>
                  <forename>K.</forename>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Guilford Press</name>
              </organization>
            </contributor>
            <edition>3</edition>
            <medium>
              <form>electronic resource</form>
              <size>8vo</size>
            </medium>
            <place>New York, NY</place>
          </bibitem>
        </relation>
                <extent>
          <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
          </locality>
        </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. 和 W. C. MCGREW. Object play in great apes: Studies in nature and captivity. 在： PELLEGRINI, Anthony D. 和 Peter K. SMITH （编辑）： <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 第第3版。 New York, NY: Guilford Press. 2005. 第89–112页。【看过：2019年9月3日】.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "zh", script: "Hans")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end
end
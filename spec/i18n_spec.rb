# encoding: utf-8

require "spec_helper"

RSpec.describe Relaton::Render do
  let(:input) do
    <<~INPUT
      <bibitem type="incollection">
        <title>Object play in great apes: Studies in nature and captivity</title>
        <uri>https://eprints.soton.ac.uk/338791/</uri>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2019-09-03</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <surname>Ramsey</surname>
              <formatted-initials>J. K.</formatted-initials>
            </name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name>
              <surname>McGrew</surname>
              <formatted-initials>W. C.</formatted-initials>
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
                  <forename initial="A">Anthony</forename>
                  <forename initial="D"/>
                </name>
              </person>
            </contributor>
            <contributor>
              <role type="editor"/>
              <person>
                <name>
                  <surname>Smith</surname>
                  <forename initial="P">Peter</forename>
                  <forename initial="K">Kenneth</forename>
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
  end

  it "renders incollection, two authors, with Arabic internationalisation" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. و W. C. MCGREW. Object play in great apes: Studies in nature and captivity. في: PELLEGRINI, Anthony D. و Peter Kenneth SMITH (محرران): «The nature of play: Great apes and humans» [electronic resource, 8vo]. ؜الطبعة؜ ٣؜. New York, NY: Guilford Press. 2005. ؜89–112 ص؜. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [ينظر: 3 سبتمبر 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "ar")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with German internationalisation" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. und W. C. MCGREW. Object play in great apes: Studies in nature and captivity. In: PELLEGRINI, Anthony D. und Peter Kenneth SMITH (Hrsg.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3 Ausg. New York, NY: Guilford Press. 2005. S. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [angesehen: 3. September 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "de")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with German internationalisation, with customisation of i18n" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. and W. C. MCGREW. Object play in great apes: Studies in nature and captivity. In: PELLEGRINI, Anthony D. and Peter Kenneth SMITH (Hrsg.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3 Ausg. New York, NY: Guilford Press. 2005. S. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [angesehen: 3. September 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "de",
                                     i18nhash: { "author_and" => "and" })
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Spanish internationalisation" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. y W. C. MCGREW. Object play in great apes: Studies in nature and captivity. En: PELLEGRINI, Anthony D. y Peter Kenneth SMITH (eds.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3.ª ed. New York, NY: Guilford Press. 2005. págs. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [visto: 3 de septiembre de 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "es")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with French internationalisation" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. et W. C. MCGREW. Object play in great apes : Studies in nature and captivity. Dans : PELLEGRINI, Anthony D. et Peter Kenneth SMITH (éd.): <em>The nature of play : Great apes and humans</em> [electronic resource, 8vo]. 3e édition. New York, NY : Guilford Press. 2005. p. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [vu : 3 septembre 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "fr")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Russian internationalisation" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. и W. C. MCGREW. Object play in great apes: Studies in nature and captivity. В: PELLEGRINI, Anthony D. и Peter Kenneth SMITH (изд.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. Третье издание. New York, NY: Guilford Press. 2005. стр. 89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [просмотрено: 3 сентября 2019 г.].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "ru")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Traditional Chinese internationalisation" do
    output = <<~OUTPUT
      <formattedref>RAMSEY，J．K．與W．C． MCGREW．〈Object play in great apes： Studies in nature and captivity〉．在： PELLEGRINI， Anthony D．與 Peter Kenneth SMITH （編輯）： <underline style="wavy">The nature of play： Great apes and humans</underline> ［electronic resource，8vo］．第第3版． New York， NY： Guilford Press．2005．第89～112頁． <link target="https://eprints.soton.ac.uk/338791/">https：//eprints．soton．ac．uk/338791/</link>．［閱：2019年9月3日］．</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "zh", script: "Hant")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Simplified Chinese internationalisation" do
    output = <<~OUTPUT
      <formattedref>RAMSEY，J．K．和W．C． MCGREW．〈Object play in great apes： Studies in nature and captivity〉．在： PELLEGRINI， Anthony D．和 Peter Kenneth SMITH （编）：《The nature of play： Great apes and humans》［electronic resource，8vo］．第第3版． New York， NY： Guilford Press．2005．第89～112页． <link target="https://eprints.soton.ac.uk/338791/">https：//eprints．soton．ac．uk/338791/</link>．［阅：2019年9月3日］．</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "zh", script: "Hans")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors, with Japanese internationalisation" do
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. と W. C. MCGREW. Object play in great apes: Studies in nature and captivity. PELLEGRINI, Anthony D. と Peter Kenneth SMITH (編): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 第3 edition. New York, NY: Guilford Press. 2005. ページ89–112. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [見た: 2019年9月3日].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "ja")
    expect(HTMLEntities.new.decode(p.render(input)))
      .to be_equivalent_to output
  end
end

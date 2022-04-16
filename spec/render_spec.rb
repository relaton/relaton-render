# encoding: utf-8

require "spec_helper"

RSpec.describe Relaton::Render do
  it "has a version number" do
    expect(Relaton::Render::VERSION).not_to be nil
  end

  it "returns formattedref" do
    input = <<~INPUT
      <bibitem type="book">
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. https://doi.org/10.1017/9781108877831. 1 vol.</formattedref>
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. https://doi.org/10.1017/9781108877831. 1 vol.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
    expect(p.render(input, embedded: false))
      .to be_equivalent_to output
    expect(p.render(input, embedded: true))
      .to be_equivalent_to output.gsub("<formattedref>", "")
        .gsub("</formattedref>", "")
  end

  it "renders book, five editors with generic class" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. https://doi.org/10.1017/9781108877831. 1 vol.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders book, five editors with specific class" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. https://doi.org/10.1017/9781108877831. 1 vol.</formattedref>
    OUTPUT
    p = Relaton::Render::Book.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders book, five editors with mismatched specific class" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    p = Relaton::Render::Booklet.new
    expect(p.render(input))
      .to raise_error(RuntimeError)
  rescue SystemExit, RuntimeError
  end

  it "renders book, five editors with manual configuration, et al. rendering, convert forenames to initials" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <date type="accessed"><on>2022-04-02</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename><forename>S.</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="page">lxii</value><value type="page">500</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>Aluffi, P., D. Anderson, M. S. Hering <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, first edition. Cambridge, UK.</formattedref>
    OUTPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em>{{ title }}</em> [{{medium}}] ,_{{ edition }} .
      {{ place }}. {{ uri }}. At:_{{ access_location }}.
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: ". " | append: "." }}, {{initials[1]  | join: ". " | append: "." }} {{surname[1] }}, {{initials[2]  | join: ". " | append: "." }} {{surname[2] }} <em>et al.</em>
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           lang: "en", edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition",
           date: { month_year: "MMMd", day_month_year: "yMMMd", date_time: "to_long_s" })
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "reuses templates from one type to another" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename><forename>S.</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="page">500</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>Aluffi, P., D. Anderson, M. S. Hering <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, first edition. Cambridge, UK.</formattedref>
    OUTPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em>{{ title }}</em> [{{medium}}] ,_{{ edition }} .
      {{ place }}. {{ uri }}. At:_{{ access_location }}.
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: ". " | append: "." }}, {{initials[1]  | join: ". " | append: "." }} {{surname[1] }}, {{initials[2]  | join: ". " | append: "." }} {{surname[2] }} <em>et al.</em>
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { booklet: template, book: "booklet" },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           lang: "en", edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition")
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders incollection, two authors" do
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
      <formattedref>RAMSEY, J. K. and W. C. MCGREW. Object play in great apes: Studies in nature and captivity. In: PELLEGRINI, Anthony D. and Peter K. SMITH (eds.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3rd edition. New York, NY: Guilford Press. 2005. pp. 89&#x2013;112. [viewed: September 3, 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders journal" do
    input = <<~INPUT
      <bibitem type="journal">
        <title>Nature</title>
        <date type="published"><from>2005</from><to>2009</to></date>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref><em>Nature</em>. 2005&#x2013;2009.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders article" do
    input = <<~INPUT
      <bibitem type="article">
              <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Aluffi</surname><forename>Paolo</forename></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><forename>David</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam</forename></name>
          </person>
        </contributor>
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        <partnumber>472</partnumber>
        <run>N.S.</run>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
            <extent>
                <localityStack>
                  <locality type="volume"><referenceFrom>1</referenceFrom></locality>
        <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
        </locality>
                </localityStack>
            </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. <em>London Mathematical Society Lecture Note Series</em> (N.S.). 1st edition. vol. 1, pp. 89–112. Cambridge, UK: Cambridge University Press. 2022. https://doi.org/10.1017/9781108877831.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders software" do
    input = <<~INPUT
      <bibitem type="software">
        <title>metanorma-standoc</title>
        <uri>https://github.com/metanorma/metanorma-standoc</uri>
        <date type="published"><on>2019-09-04</on></date>
        <contributor>
          <role type="author"/>
          <organization>
            <name>Ribose Inc.</name>
          </organization>
        </contributor>
        <contributor>
          <role type="distributor"/>
          <organization>
            <name>GitHub</name>
          </organization>
        </contributor>
        <edition>1.3.1</edition>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>Ribose Inc. <em>metanorma-standoc</em>. Version 1.3.1. September 4, 2019. https://github.com/metanorma/metanorma-standoc.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders standard" do
    input = <<~INPUT
      <bibitem type="standard">
        <title>Intellectual Property Rights in IETF technology</title>
        <uri>https://www.ietf.org/rfc/rfc3979.txt</uri>
        <docidentifier type="RFC">RFC 3979</docidentifier>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2012-06-18</on></date>
        <contributor>
          <role type="author"/>
          <organization>
            <name>Internet Engineering Task Force</name>
            <abbreviation>IETF</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Bradner</surname><initials>S.</initials></name>
          </person>
        </contributor>
        <medium>
          <carrier>Online</carrier>
        </medium>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>Internet Engineering Task Force. <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. RFC 3979. https://www.ietf.org/rfc/rfc3979.txt. [viewed: June 18, 2012].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders dataset" do
    input = <<~INPUT
      <bibitem type="dataset">
        <title>Children of Immigrants. Longitudinal Sudy (CILS) 1991–2006 ICPSR20520</title>
        <uri>https://doi.org/10.3886/ICPSR20520.v2</uri>
        <date type="published"><on>2012-01-23</on></date>
        <date type="accessed"><on>2018-05-06</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Portes</surname><forename>Alejandro</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Rumbaut</surname><forename>Rubén</forename><forename>G.</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="distributor"/>
          <organization>
            <name>Inter-University Consortium for Political and Social Research</name>
          </organization>
        </contributor>
        <edition>2</edition>
        <medium>
          <genre>dataset</genre>
        </medium>
          <size>
            <value type="data">501 GB</value>
          </size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>PORTES, Alejandro and Rubén G. RUMBAUT. <em>Children of Immigrants. Longitudinal Sudy (CILS) 1991–2006 ICPSR20520</em>. Version 2. Dataset. January 23, 2012. https://doi.org/10.3886/ICPSR20520.v2. 501 GB. [viewed: May 6, 2018].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders website" do
    input = <<~INPUT
      <bibitem type="website">
        <title>Language Log</title>
        <uri>https://languagelog.ldc.upenn.edu/nll/</uri>
        <date type="published"><from>2003</from></date>
        <date type="accessed"><on>2019-09-03</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Liberman</surname><forename>Mark</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Pullum</surname><forename>Geoffrey</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>University of Pennsylvania</name>
          </organization>
        </contributor>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>LIBERMAN, Mark and Geoffrey PULLUM. <em>Language Log</em>. University of Pennsylvania. 2003&#x2013;. https://languagelog.ldc.upenn.edu/nll/. [viewed: September 3, 2019].</formattedref>

    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders unpublished" do
    input = <<~INPUT
      <bibitem type="unpublished">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338797/</uri>
        <date type="created"><on>2012</on></date>
        <date type="accessed"><on>2020-06-24</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Jenkins</surname><initials>S.</initials></name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Ruostekoski</surname><forename>Janne</forename></name>
          </person>
        </contributor>
        <medium>
          <genre>preprint</genre>
        </medium>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>JENKINS and Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em>. Preprint. 2012. https://eprints.soton.ac.uk/338797/. [viewed: June 24, 2020].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders untyped" do
    input = <<~INPUT
      <bibitem>
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338797/</uri>
        <date type="created"><on>2012</on></date>
        <date type="accessed"><on>2020-06-24</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Jenkins</surname><initials>S.</initials></name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Ruostekoski</surname><forename>Janne</forename></name>
          </person>
        </contributor>
        <medium>
          <genre>preprint</genre>
        </medium>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>JENKINS and Janne RUOSTEKOSKI. Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice. 2012.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders month-year dates" do
    input = <<~INPUT
      <bibitem type="unpublished">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338797/</uri>
        <date type="accessed"><on>2020-06</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Jenkins</surname><initials>S.</initials></name>
          </person>
        </contributor>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Ruostekoski</surname><forename>Janne</forename></name>
          </person>
        </contributor>
        <medium>
          <genre>preprint</genre>
        </medium>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>JENKINS and Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em>. Preprint. June 2020. https://eprints.soton.ac.uk/338797/. [viewed: June 2020].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end
end
# encoding: utf-8

require "spec_helper"

RSpec.describe Relaton::Render::Citations do
  it "apply et al. to author-date citations" do
    input = <<~INPUT
      <references>
        <bibitem type="book" id="A">
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
      </references>
    INPUT
    etal = <<~TEMPLATE
      {% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] }}{% endif %}, {% if nonpersonal[1] %}{{ nonpersonal[1] }}{% else %}{{surname[1] }}{% endif %} <em>et al.</em>
    TEMPLATE
    output = 
      {"A"=>{:author=>"Aluffi, Anderson, Hering, Mustaţă <em>et al.</em>", :date=>"2022", :citation=>"Aluffi, Anderson, Hering, Mustaţă <em>et al.</em> 2022", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                            etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
    output = 
      {"A"=>{:author=>"Aluffi, Anderson, Hering <em>et al.</em>", :date=>"2022", :citation=>"Aluffi, Anderson, Hering <em>et al.</em> 2022", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                            etal_display: 3, etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
    output = 
      {"A"=>{:author=>"Aluffi, Anderson <em>et al.</em>", :date=>"2022", :citation=>"Aluffi, Anderson <em>et al.</em> 2022", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                            etal_display: 2, etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
    output = 
      {"A"=>{:author=>"Aluffi <em>et al.</em>", :date=>"2022", :citation=>"Aluffi <em>et al.</em> 2022", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                            etal_display: 1, etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
  end

  it "disambiguates author-cite citations" do
    input = <<~INPUT
      <references>
        <bibitem type="book" id="A">
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
        <bibitem type="book" id="B">
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
        <bibitem type="book" id="C">
        <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. https://doi.org/10.1017/9781108877831. 1 vol.</formattedref>
          <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
          <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
          <docidentifier type="ISBN">9781108877831</docidentifier>
          <date type="published"><on>2021</on></date>
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
        <bibitem type="book" id="D">
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
      </references>
    INPUT
    output = 
      {"A"=>{:author=>"Aluffi, Anderson, Hering, Mustaţă and Payne", :date=>"2022a", :citation=>"Aluffi, Anderson, Hering, Mustaţă and Payne 2022a", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."},
      "B"=>{:author=>"Aluffi, Anderson, Hering, Mustaţă and Payne", :date=>"2022b", :citation=>"Aluffi, Anderson, Hering, Mustaţă and Payne 2022b", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."},
      "C"=>{:author=>"Aluffi, Anderson, Hering, Mustaţă and Payne", :date=>"2021", :citation=>"Aluffi, Anderson, Hering, Mustaţă and Payne 2021", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2021. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."},
      "D"=>{:author=>"Aluffi and Anderson", :date=>"2022", :citation=>"Aluffi and Anderson 2022", :formattedref=>"ALUFFI, Paolo and David ANDERSON (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    p = Relaton::Render::General.new
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
  end

  it "adds date accessed as required to set of citations" do
    input = <<~INPUT
      <references>
        <bibitem type="book" id="A">
          <title>Book 1</title>
          <uri>https://github.com/metanorma/metanorma-standoc</uri>
          <date type="published"><on>2021</on></date>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
            </person>
          </contributor>
           <contributor>
                <role type="publisher"/>
                <organization>
                  <name>Cambridge University Press</name>
                </organization>
              </contributor>
              <place>Cambridge, UK</place>
        </bibitem>
        <bibitem type="book" id="B">
          <title>Book 2</title>
          <uri>https://github.com/metanorma/metanorma-standoc</uri>
          <date type="published"><on>2022</on></date>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
            </person>
          </contributor>
           <contributor>
                <role type="publisher"/>
                <organization>
                  <name>Cambridge University Press</name>
                </organization>
              </contributor>
              <place>Cambridge, UK</place>
        </bibitem>
        <bibitem type="standard" id="C">
          <title>Standard 1</title>
          <date type="published"><on>2023</on></date>
          <uri>https://github.com/metanorma/metanorma-standoc</uri>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
            </person>
          </contributor>
           <contributor>
                <role type="publisher"/>
                <organization>
                  <name>Cambridge University Press</name>
                </organization>
              </contributor>
              <place>Cambridge, UK</place>
        </bibitem>
        <bibitem type="standard" id="D">
          <title>Standard 2</title>
          <uri>https://github.com/metanorma/metanorma-standoc</uri>
          <date type="published"><on>2024</on></date>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
            </person>
          </contributor>
           <contributor>
                <role type="publisher"/>
                <organization>
                  <name>Cambridge University Press</name>
                </organization>
              </contributor>
              <place>Cambridge, UK</place>
        </bibitem>
      </references>
    INPUT
    template1 = <<~TEMPLATE
      {{ creatornames }} ({{date}}) . <em>{{ title }}</em> {{ uri }}.
    TEMPLATE
    template2 = <<~TEMPLATE
      {{ creatornames }} ({{date}}) . <em>{{ title }}</em> {{ uri }}. Accessed: {{ date_accessed }}.
    TEMPLATE
    output = 
      {"A"=>{:author=>"Aluffi", :date=>"2021", :citation=>"Aluffi 2021", :formattedref=>"ALUFFI, Paolo (2021). <em>Book 1</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."},
      "B"=>{:author=>"Aluffi", :date=>"2022", :citation=>"Aluffi 2022", :formattedref=>"ALUFFI, Paolo (2022). <em>Book 2</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."},
      "C"=>{:author=>"Aluffi", :date=>"2023", :citation=>"Aluffi 2023", :formattedref=>"ALUFFI, Paolo (2023). <em>Standard 1</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>. Accessed: #{Date.today.strftime('%B %-d, %Y')}."},
      "D"=>{:author=>"Aluffi", :date=>"2024", :citation=>"Aluffi 2024", :formattedref=>"ALUFFI, Paolo (2024). <em>Standard 2</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>. Accessed: #{Date.today.strftime('%B %-d, %Y')}."}}
    p = Relaton::Render::General
      .new(template: { book: template1, standard: template2 })
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
  end

  it "generates generic citations" do
    input = <<~INPUT
      <references>
        <bibitem type="book" id="A">
          <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
          <docidentifier>ABC1</docidentifier>
          <date type="published"><on>2022</on></date>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
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
        <bibitem type="book" id="B">
          <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
          <docidentifier>ABC2</docidentifier>
          <date type="published"><on>2022</on></date>
          <contributor>
            <role type="editor"/>
            <person>
              <name><surname>Aluffi</surname><forename>Paolo</forename></name>
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
      </references>
    INPUT
    output = 
      {"A"=>{:citation=>nil, :formattedref=>"ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. ABC1. 1 vol."},
      "B"=>{:citation=>nil, :formattedref=>"ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. ABC2. 1 vol."}}
    p = Relaton::Render::General.new
    expect(p.render_all(input, type: nil))
      .to be_equivalent_to output
  end

  it "rejects other types of citation" do
    input = <<~INPUT
          <references>
        <bibitem type="book" id="A">
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
      </references>
    INPUT
    p = Relaton::Render::General.new
    expect(p.render_all(input, type: "pizza"))
      .to raise_error(RuntimeError)
  rescue SystemExit, RuntimeError
  end
end

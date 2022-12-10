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
    output = <<~OUTPUT
      {"A"=>{:author=>"Aluffi, Anderson, Hering, Mustaţă <em>et al.</em>", :date=>"2022", :citation=>"Aluffi, Anderson, Hering, Mustaţă <em>et al.</em> 2022", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    OUTPUT
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4, etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
    output = <<~OUTPUT
      {"A"=>{:author=>"Aluffi, Anderson, Hering <em>et al.</em>", :date=>"2022", :citation=>"Aluffi, Anderson, Hering <em>et al.</em> 2022", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    OUTPUT
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4, etal_display: 3, etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
    output = <<~OUTPUT
      {"A"=>{:author=>"Aluffi, Anderson <em>et al.</em>", :date=>"2022", :citation=>"Aluffi, Anderson <em>et al.</em> 2022", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    OUTPUT
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4, etal_display: 2, etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
    output = <<~OUTPUT
      {"A"=>{:author=>"Aluffi <em>et al.</em>", :date=>"2022", :citation=>"Aluffi <em>et al.</em> 2022", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    OUTPUT
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4, etal_display: 1, etal: etal },
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
    output = <<~OUTPUT
      {"A"=>{:author=>"Aluffi, Anderson, Hering, Mustaţă and Payne", :date=>"2022a", :citation=>"Aluffi, Anderson, Hering, Mustaţă and Payne 2022a", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."},
      "B"=>{:author=>"Aluffi, Anderson, Hering, Mustaţă and Payne", :date=>"2022b", :citation=>"Aluffi, Anderson, Hering, Mustaţă and Payne 2022b", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."},
      "C"=>{:author=>"Aluffi, Anderson, Hering, Mustaţă and Payne", :date=>"2021", :citation=>"Aluffi, Anderson, Hering, Mustaţă and Payne 2021", :formattedref=>"ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2021. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."},
      "D"=>{:author=>"Aluffi and Anderson", :date=>"2022", :citation=>"Aluffi and Anderson 2022", :formattedref=>"ALUFFI, Paolo and David ANDERSON (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."}}
    OUTPUT
    p = Relaton::Render::General.new
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
    output = <<~OUTPUT
      {"A"=>{:citation=>nil, :formattedref=>"ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. ABC1. 1 vol."},
      "B"=>{:citation=>nil, :formattedref=>"ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. ABC2. 1 vol."}}
    OUTPUT
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

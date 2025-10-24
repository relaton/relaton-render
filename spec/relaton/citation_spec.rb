# encoding: utf-8

require_relative "../spec_helper"

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
    output = {
      "A" => {
        author: "Aluffi, Anderson, Hering, Mustaţă <em>et al.</em>",
        date: "2022",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi, Anderson, Hering, Mustaţă <em>et al.</em> 2022",
          author_date_br: "Aluffi, Anderson, Hering, Mustaţă <em>et al.</em> (2022)",
          author: "Aluffi, Anderson, Hering, Mustaţă <em>et al.</em>",
          date: "2022",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      }
    }
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                            etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
    output = {
      "A" => {
        author: "Aluffi, Anderson, Hering <em>et al.</em>",
        date: "2022",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi, Anderson, Hering <em>et al.</em> 2022",
          author_date_br: "Aluffi, Anderson, Hering <em>et al.</em> (2022)",
          author: "Aluffi, Anderson, Hering <em>et al.</em>",
          date: "2022",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      }
    }
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                            etal_display: 3, etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
    output = {
      "A" => {
        author: "Aluffi, Anderson <em>et al.</em>",
        date: "2022",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi, Anderson <em>et al.</em> 2022",
          author_date_br: "Aluffi, Anderson <em>et al.</em> (2022)",
          author: "Aluffi, Anderson <em>et al.</em>",
          date: "2022",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      }
    }
    p = Relaton::Render::General.new(
      authorcitetemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                            etal_display: 2, etal: etal },
    )
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
    output = {
      "A" => {
        author: "Aluffi <em>et al.</em>",
        date: "2022",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi <em>et al.</em> 2022",
          author_date_br: "Aluffi <em>et al.</em> (2022)",
          author: "Aluffi <em>et al.</em>",
          date: "2022",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      }
    }
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
    output = {
      "A" => {
        author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
        date: "2022a",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi, Anderson, Hering, Mustaţă and Payne 2022a",
          author_date_br: "Aluffi, Anderson, Hering, Mustaţă and Payne (2022a)",
          author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
          date: "2022a",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      },
      "B" => {
        author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
        date: "2022b",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi, Anderson, Hering, Mustaţă and Payne 2022b",
          author_date_br: "Aluffi, Anderson, Hering, Mustaţă and Payne (2022b)",
          author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
          date: "2022b",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      },
      "C" => {
        author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
        date: "2021",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2021. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi, Anderson, Hering, Mustaţă and Payne 2021",
          author_date_br: "Aluffi, Anderson, Hering, Mustaţă and Payne (2021)",
          author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
          date: "2021",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2021. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2021. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      },
      "D" => {
        author: "Aluffi and Anderson",
        date: "2022",
        citation: {
          default: "",
          short: "ALUFFI, Paolo and David ANDERSON (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi and Anderson 2022",
          author_date_br: "Aluffi and Anderson (2022)",
          author: "Aluffi and Anderson",
          date: "2022",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo and David ANDERSON (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo and David ANDERSON (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      }
    }
    p = Relaton::Render::General.new
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
  end

    it "do not disambiguate author-cite citations for empty authors" do
    input = <<~INPUT
      <references>
        <bibitem type="book" id="A">
        <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. https://doi.org/10.1017/9781108877831. 1 vol.</formattedref>
          <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
          <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
          <docidentifier type="ISBN">9781108877831</docidentifier>
          <date type="published"><on>2022</on></date>
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
    output = {
      "A" => {
        author: nil,
        date: "2022",
        citation: {
          default: "",
          short: "<em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "2022",
          author_date_br: "(2022)",
          author: nil,
          date: "2022",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "<em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "<em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      },
      "B" => {
        author: nil,
        date: "2022",
        citation: {
          default: "",
          short: "<em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "2022",
          author_date_br: "(2022)",
          author: nil,
          date: "2022",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "<em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "<em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      }
    }
    p = Relaton::Render::General.new
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
  end

  it "do not disambiguate author-cite citations for empty dates" do
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
    output = {
      "A" => {
        author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
        date: "2022a",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi, Anderson, Hering, Mustaţă and Payne 2022a",
          author_date_br: "Aluffi, Anderson, Hering, Mustaţă and Payne (2022a)",
          author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
          date: "2022a",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      },
      "B" => {
        author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
        date: "2022b",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi, Anderson, Hering, Mustaţă and Payne 2022b",
          author_date_br: "Aluffi, Anderson, Hering, Mustaţă and Payne (2022b)",
          author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
          date: "2022b",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      },
      "C" => {
        author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
        date: "2021",
        citation: {
          default: "",
          short: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2021. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi, Anderson, Hering, Mustaţă and Payne 2021",
          author_date_br: "Aluffi, Anderson, Hering, Mustaţă and Payne (2021)",
          author: "Aluffi, Anderson, Hering, Mustaţă and Payne",
          date: "2021",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2021. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2021. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      },
      "D" => {
        author: "Aluffi and Anderson",
        date: "2022",
        citation: {
          default: "",
          short: "ALUFFI, Paolo and David ANDERSON (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.",
          author_date: "Aluffi and Anderson 2022",
          author_date_br: "Aluffi and Anderson (2022)",
          author: "Aluffi and Anderson",
          date: "2022",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo and David ANDERSON (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
        },
        formattedref: "ALUFFI, Paolo and David ANDERSON (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol."
      }
    }
    p = Relaton::Render::General.new
    expect(p.render_all(input, type: "author-date"))
      .to be_equivalent_to output
  end

  it "does not add date accessed by default to set of citations" do
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
      {{ creatornames }} ({{date}}) . <em>{{ title }}</em> {{ uri }}. Accessed:_{{ date_accessed }}.
    TEMPLATE
    output = {
      "A" => {
        author: "Aluffi",
        date: "2021",
        citation: {
          default: "",
          short: "ALUFFI, Paolo (ed.). <em>Book 1</em>. Cambridge, UK: Cambridge University Press. 2021.",
          author_date: "Aluffi 2021",
          author_date_br: "Aluffi (2021)",
          author: "Aluffi",
          date: "2021",
          reference_tag: nil,
          title: "Book 1",
          title_reference_tag: "Book 1",
          full: "ALUFFI, Paolo (2021). <em>Book 1</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."
        },
        formattedref: "ALUFFI, Paolo (2021). <em>Book 1</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."
      },
      "B" => {
        author: "Aluffi",
        date: "2022",
        citation: {
          default: "",
          short: "ALUFFI, Paolo (ed.). <em>Book 2</em>. Cambridge, UK: Cambridge University Press. 2022.",
          author_date: "Aluffi 2022",
          author_date_br: "Aluffi (2022)",
          author: "Aluffi",
          date: "2022",
          reference_tag: nil,
          title: "Book 2",
          title_reference_tag: "Book 2",
          full: "ALUFFI, Paolo (2022). <em>Book 2</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."
        },
        formattedref: "ALUFFI, Paolo (2022). <em>Book 2</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."
      },
      "C" => {
        author: "Aluffi",
        date: "2023",
        citation: {
          default: "",
          short: "ALUFFI, Paolo (ed.). <em>Standard 1</em>. Cambridge, UK: Cambridge University Press. 2023.",
          author_date: "Aluffi 2023",
          author_date_br: "Aluffi (2023)",
          author: "Aluffi",
          date: "2023",
          reference_tag: nil,
          title: "Standard 1",
          title_reference_tag: "Standard 1",
          full: "ALUFFI, Paolo (2023). <em>Standard 1</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."
        },
        formattedref: "ALUFFI, Paolo (2023). <em>Standard 1</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."
      },
      "D" => {
        author: "Aluffi",
        date: "2024",
        citation: {
          default: "",
          short: "ALUFFI, Paolo (ed.). <em>Standard 2</em>. Cambridge, UK: Cambridge University Press. 2024.",
          author_date: "Aluffi 2024",
          author_date_br: "Aluffi (2024)",
          author: "Aluffi",
          date: "2024",
          reference_tag: nil,
          title: "Standard 2",
          title_reference_tag: "Standard 2",
          full: "ALUFFI, Paolo (2024). <em>Standard 2</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."
        },
        formattedref: "ALUFFI, Paolo (2024). <em>Standard 2</em> <link target='https://github.com/metanorma/metanorma-standoc'>https://github.com/metanorma/metanorma-standoc</link>."
      }
    }
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
          <docidentifier scope="biblio-tag">Fulton1</docidentifier>
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
          <docidentifier scope="biblio-tag">Fulton2</docidentifier>
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
                <bibitem type="standard" id="C">
        <title>Intellectual Property Rights in IETF technology</title>
        <uri>https://www.ietf.org/rfc/rfc3979.txt</uri>
        <docidentifier type="RFC">RFC 3979</docidentifier>
        <docidentifier type="DOI">https://doi.org/10.3886/ICPSR20520.v2</docidentifier>
        <docidentifier scope="biblio-tag">[33]</docidentifier>
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
        <status>
          <stage>valid</stage>
        </status>
        <medium>
          <carrier>Online</carrier>
        </medium>
      </bibitem>
      </references>
    INPUT
    output = {
      "A" => {
        author: "Aluffi",
        date: "2022a",
        citation: {
          default: "ABC1",
          short: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. ABC1. 1 vol.",
          author_date: "Aluffi 2022a",
          author_date_br: "Aluffi (2022a)",
          author: "Aluffi",
          date: "2022a",
          reference_tag: "Fulton1",
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday Fulton1",
          full: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. ABC1. 1 vol."
        },
        formattedref: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. ABC1. 1 vol."
      },
      "B" => {
        author: "Aluffi",
        date: "2022b",
        citation: {
          default: "ABC2",
          short: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. ABC2. 1 vol.",
          author_date: "Aluffi 2022b",
          author_date_br: "Aluffi (2022b)",
          author: "Aluffi",
          date: "2022b",
          reference_tag: "Fulton2",
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday Fulton2",
          full: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. ABC2. 1 vol."
        },
        formattedref: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. ABC2. 1 vol."
      },
      "C" => {
        author: "Internet Engineering Task Force",
        date: "2005",
        citation: {
          default: "RFC 3979",
          short: "Internet Engineering Task Force. RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2",
          author_date: "Internet Engineering Task Force 2005",
          author_date_br: "Internet Engineering Task Force (2005)",
          author: "Internet Engineering Task Force",
          date: "2005",
          reference_tag: "[33]",
          title: "Intellectual Property Rights in IETF technology",
          title_reference_tag: "Intellectual Property Rights in IETF technology [33]",
          full: "Internet Engineering Task Force. RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2. <link target='https://www.ietf.org/rfc/rfc3979.txt'>https://www.ietf.org/rfc/rfc3979.txt</link>. [viewed: June 18, 2012]."
        },
        formattedref: "Internet Engineering Task Force. RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2. <link target='https://www.ietf.org/rfc/rfc3979.txt'>https://www.ietf.org/rfc/rfc3979.txt</link>. [viewed: June 18, 2012]."
      }
    }
    p = Relaton::Render::General.new
    expect(p.render_all(input, type: nil))
      .to be_equivalent_to output
  end

  it "generates short citations" do
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
                <bibitem type="standard" id="C">
        <title>Intellectual Property Rights in IETF technology</title>
        <uri>https://www.ietf.org/rfc/rfc3979.txt</uri>
        <docidentifier type="RFC">RFC 3979</docidentifier>
        <docidentifier type="DOI">https://doi.org/10.3886/ICPSR20520.v2</docidentifier>
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
        <status>
          <stage>valid</stage>
        </status>
        <medium>
          <carrier>Online</carrier>
        </medium>
      </bibitem>
      </references>
    INPUT
    output = {
      "A" => {
        author: "Aluffi",
        date: "2022a",
        citation: {
          default: "ABC1",
          short: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. ABC1. 1 vol.",
          author_date: "Aluffi 2022a",
          author_date_br: "Aluffi (2022a)",
          author: "Aluffi",
          date: "2022a",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. ABC1. 1 vol."
        },
        formattedref: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. ABC1. 1 vol."
      },
      "B" => {
        author: "Aluffi",
        date: "2022b",
        citation: {
          default: "ABC2",
          short: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. ABC2. 1 vol.",
          author_date: "Aluffi 2022b",
          author_date_br: "Aluffi (2022b)",
          author: "Aluffi",
          date: "2022b",
          reference_tag: nil,
          title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          title_reference_tag: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
          full: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. ABC2. 1 vol."
        },
        formattedref: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. ABC2. 1 vol."
      },
      "C" => {
        author: "Internet Engineering Task Force",
        date: "2005",
        citation: {
          default: "RFC 3979",
          short: "Internet Engineering Task Force. RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2",
          author_date: "Internet Engineering Task Force 2005",
          author_date_br: "Internet Engineering Task Force (2005)",
          author: "Internet Engineering Task Force",
          date: "2005",
          reference_tag: nil,
          title: "Intellectual Property Rights in IETF technology",
          title_reference_tag: "Intellectual Property Rights in IETF technology",
          full: "Internet Engineering Task Force. RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2. <link target='https://www.ietf.org/rfc/rfc3979.txt'>https://www.ietf.org/rfc/rfc3979.txt</link>. [viewed: June 18, 2012]."
        },
        formattedref: "Internet Engineering Task Force. RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2. <link target='https://www.ietf.org/rfc/rfc3979.txt'>https://www.ietf.org/rfc/rfc3979.txt</link>. [viewed: June 18, 2012]."
      }
    }
    p = Relaton::Render::General.new
    expect(p.render_all(input, type: "short"))
      .to be_equivalent_to output

    output = {
      "A" => {
        author: "Aluffi",
        date: "2022a",
        citation: {
          default: "ABC1",
          short: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022a. ABC1. 1 vol.",
          author_date: "Aluffi 2022a",
          full: "ALUFFI, Paolo. Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. 2022a."
        },
        formattedref: "ALUFFI, Paolo. Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. 2022a."
      },
      "B" => {
        author: "Aluffi",
        date: "2022b",
        citation: {
          default: "ABC2",
          short: "ALUFFI, Paolo (ed.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022b. ABC2. 1 vol.",
          author_date: "Aluffi 2022b",
          full: "ALUFFI, Paolo. Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. 2022b."
        },
        formattedref: "ALUFFI, Paolo. Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. 2022b."
      },
      "C" => {
        author: "Internet Engineering Task Force",
        date: "2005",
        citation: {
          default: "RFC 3979",
          short: "Internet Engineering Task Force. Intellectual Property Rights in IETF technology. 2005.",
          author_date: "Internet Engineering Task Force 2005",
          full: "Internet Engineering Task Force. RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2"
        },
        formattedref: "Internet Engineering Task Force. RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2"
      }
    }
    p = Relaton::Render::General.new( citetemplate:{
      author_date: "{{ author }} {{ date}}",
      short: {
        book: "{{ creatornames }} ({{role}}) . {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} [{{medium}}] . {{ edition | capitalize_first }}. ({{ series }}.) {% if place %}{{place}}{%else%}{{ labels['no_place']}}{%endif%}: {{publisher}}. {{date}}. {{ labels['updated'] | capitalize }}:_{{date_updated}}. {{ authoritative_identifier | join: '. ' }}. {{ other_identifier | join: '. ' }}. {{size}}. {{extent}}."
      }},
      template: { standard: "{{ creatornames }} ({{ role}}) . {{ authoritative_identifier | join: '|' }}: {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} . {{ medium | capitalize }}. {{ edition | capitalize_first }}. {{ place }}: {{ publisher }}. {{date}}. {{size}}. {{ extent }}. {{ other_identifier | join: '. ' }}" }
                                    )
    expect(p.render_all(input, type: "short"))
      .to be_equivalent_to output

  end
end

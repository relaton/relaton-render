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
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTA&#x162;&#x102; and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, UK: Cambridge University Press. 2022. https://doi.org/10.1017/9781108877831. 1 vol.</formattedref>
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
            <name><surname>Anderson</surname><forename>David</forename><forename>Herbert</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena Marie</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename><forename>H.</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam H.</forename></name>
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
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      ALUFFI, Paolo, David Herbert ANDERSON, Milena Marie HERING, Mircea H. MUSTAŢĂ and Sam H. PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) n.p.: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to "<formattedref>#{output}</formattedref>"
    data, template = p.parse(input)
    expect(p.liquid(data, template))
      .to be_equivalent_to output
    hash = {
      authorcite: "Aluffi, Anderson, Hering, Mustaţă and Payne",
      authorizer: "Cambridge University Press",
      authorizer_raw: [{ nonpersonal: "Cambridge University Press" }],
      creatornames: "ALUFFI, Paolo, David Herbert ANDERSON, Milena Marie HERING, Mircea H. MUSTAŢĂ and Sam H. PAYNE",
      creators: [
        { given: "Paolo", initials: ["P."], middle: [], surname: "Aluffi" },
        { given: "David", initials: ["D.", "H."], middle: ["Herbert"],
          surname: "Anderson" },
        { given: "Milena Marie", initials: ["M.", "M."], middle: [],
          surname: "Hering" },
        { given: "Mircea", initials: ["M.", "H."], middle: ["H."],
          surname: "Mustaţă" },
        { given: "Sam H.", initials: ["S.", "H."], middle: [],
          surname: "Payne" },
      ],
      date: "2022",
      doi: ["https://doi.org/10.1017/9781108877831"],
      draft_raw: { iteration: nil, status: nil },
      edition: "1st edition",
      edition_raw: "1",
      other_identifier: ["DOI: https://doi.org/10.1017/9781108877831",
                         "ISBN: 9781108877831"],
      publisher: "Cambridge University Press",
      publisher_abbrev: "Cambridge University Press",
      publisher_abbrev_raw: ["Cambridge University Press"],
      publisher_raw: [{ nonpersonal: "Cambridge University Press" }],
      role: "eds.",
      role_raw: "editor",
      series: "London Mathematical Society Lecture Note Series 472",
      series_num: "472",
      series_title: "London Mathematical Society Lecture Note Series",
      size: "1 vol.",
      size_raw: { "volume" => ["1"] },
      title: "Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday",
      type: "book",
    }
    expect(metadata(data))
      .to eq(hash)
  end

  it "renders book, five editors with specific class, broken down place" do
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
            <place><city>Cambridge</city>
            <region>Cambridgeshire</region>
            <country>UK</country>
            </place>
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>. 1st edition. (London Mathematical Society Lecture Note Series 472.) Cambridge, Cambridgeshire, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. 1 vol.</formattedref>
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

  it "renders book, five editors with manual configuration, " \
     "et al. rendering, convert forenames to initials #1" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">10.1017/9781108877831</docidentifier>
        <docidentifier type="DOI">10.1017/9781108877832</docidentifier>
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
            <name><surname>Anderson</surname><formatted-initials>D. X.</formatted-initials></name>
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
            <name><surname>Mustaţă</surname><formatted-initials>M.M.</formatted-initials></name>
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
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="page">lxii</value><value type="page">500</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>Aluffi, P, DX Anderson, MS Hering, MM Mustaţă and S Payne, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, 1st edition. Cambridge, UK: CUP. DOI: 10.1017/9781108877831, 10.1017/9781108877832</formattedref>
    OUTPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em>{{ title }}</em> [{{medium}}] ,_{{ edition }} .
      {{ place }} : {{ publisher_abbrev }} . {{ uri }}. At:_{{ access_location }}. DOI:_{{ doi | join: ", " }}
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: "" | remove: "." | remove: "_" }}, {{initials[1]  | join: "" | remove: "." | remove: "_" }} {{surname[1] }}, {{initials[2]  | join: "" | remove: "." | remove: "_" }} {{surname[2] }},  {{initials[3]  | join: "" | remove: "." | remove: "_" }} {{surname[3] }} <em>et al.</em>
    TEMPLATE
    more = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: "" | remove: "." | remove: "_" }}, {{initials[1]  | join: "" | remove: "." | remove: "_" }} {{surname[1] }} {{ labels['author_and'] }} {{initials[2]  | join: "" | remove: "." | remove: "_" }} {{surname[2] }}
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}",
                           more: more,
                           etal_count: 5, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           language: "en",
           edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition",
           date: { month_year: "MMMd", day_month_year: "yMMMd",
                   date_time: "to_long_s" })
    expect(p.render(input))
      .to be_equivalent_to output
    output = <<~OUTPUT
      <formattedref>Aluffi, P, DX Anderson, MS Hering, MM Mustaţă <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, 1st edition. Cambridge, UK: CUP. DOI: 10.1017/9781108877831, 10.1017/9781108877832</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}",
                           etal_count: 4, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           language: "en",
           edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition",
           date: { month_year: "MMMd", day_month_year: "yMMMd",
                   date_time: "to_long_s" })
    expect(p.render(input))
      .to be_equivalent_to output
    output = <<~OUTPUT
      <formattedref>Aluffi, P, DX Anderson, MS Hering <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, 1st edition. Cambridge, UK: CUP. DOI: 10.1017/9781108877831, 10.1017/9781108877832</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                           etal_display: 3, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           language: "en",
           edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition",
           date: { month_year: "MMMd", day_month_year: "yMMMd",
                   date_time: "to_long_s" })
    expect(p.render(input))
      .to be_equivalent_to output
    output = <<~OUTPUT
      <formattedref>Aluffi, P, DX Anderson <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, 1st edition. Cambridge, UK: CUP. DOI: 10.1017/9781108877831, 10.1017/9781108877832</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                           etal_display: 2, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           language: "en",
           edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition",
           date: { month_year: "MMMd", day_month_year: "yMMMd",
                   date_time: "to_long_s" })
    expect(p.render(input))
      .to be_equivalent_to output
    output = <<~OUTPUT
      <formattedref>Aluffi, P <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, 1st edition. Cambridge, UK: CUP. DOI: 10.1017/9781108877831, 10.1017/9781108877832</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                           etal_display: 1, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           language: "en",
           edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition",
           date: { month_year: "MMMd", day_month_year: "yMMMd",
                   date_time: "to_long_s" })
    expect(p.render(input))
      .to be_equivalent_to output
    output = <<~OUTPUT
      <formattedref>Aluffi, P _et al._, eds. (2022). _Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday_, 1st edition. Cambridge, UK: CUP. DOI: 10.1017/9781108877831, 10.1017/9781108877832</formattedref>
    OUTPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . \\_{{ title }}\\_ [{{medium}}] ,_{{ edition }} .
      {{ place }} : {{ publisher_abbrev }} . {{ uri }}. At:_{{ access_location }}. DOI:_{{ doi | join: ", " }}
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: "" | remove: "." | remove: "_" }}, {{initials[1]  | join: "" | remove: "." | remove: "_" }} {{surname[1] }}, {{initials[2]  | join: "" | remove: "." | remove: "_" }} {{surname[2] }},  {{initials[3]  | join: "" | remove: "." | remove: "_" }} {{surname[3] }} \\_et al.\\_
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 4,
                           etal_display: 1, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           language: "en",
           edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition",
           date: { month_year: "MMMd", day_month_year: "yMMMd",
                   date_time: "to_long_s" })
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders book, convert forenames to initials #2" do
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
            <name><surname>Anderson</surname><forename>David</forename><forename>Herbert</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Hering</surname><forename>Milena Marie</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Mustaţă</surname><forename>Mircea</forename><forename>H.</forename></name>
          </person>
        </contributor>
        <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Payne</surname><forename>Sam H.</forename></name>
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
          <size><value type="volume">1</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>Aluffi, P, DH Anderson, MM Hering, MH Mustaţă and SH Payne, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, 1st edition.: Cambridge University Press. DOI: https://doi.org/10.1017/9781108877831</formattedref>
    OUTPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em>{{ title }}</em> [{{medium}}] ,_{{ edition }} .
      {{ place }} : {{ publisher_abbrev }} . {{ uri }}. At:_{{ access_location }}. DOI:_{{ doi | join: ", " }}
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: "" | remove: "." | remove: "_" }}, {{initials[1]  | join: "" | remove: "." | remove: "_" }} {{surname[1] }}, {{initials[2]  | join: "" | remove: "." | remove: "_" }} {{surname[2] }},  {{initials[3]  | join: "" | remove: "." | remove: "_" }} {{surname[3] }} <em>et al.</em>
    TEMPLATE
    more = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: "" | remove: "." | remove: "_" }}, {{initials[1]  | join: "" | remove: "." | remove: "_" }} {{surname[1] }} {{ labels['author_and'] }} {{initials[2]  | join: "" | remove: "." | remove: "_" }} {{surname[2] }}
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}",
                           more: more,
                           etal_count: 5, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           language: "en",
           edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition",
           date: { month_year: "MMMd", day_month_year: "yMMMd",
                   date_time: "to_long_s" })
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "processes capitalize_first" do
    input = <<~INPUT
      <bibitem type="book">
        <title>facets of algebraic geometry: a collection in honor of william fulton's 80th birthday</title>
        <docidentifier type="DOI">10.1017/9781108877831</docidentifier>
        <docidentifier type="DOI">10.1017/9781108877832</docidentifier>
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
            <name><surname>Anderson</surname><formatted-initials>D. X.</formatted-initials></name>
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
            <name><surname>Mustaţă</surname><formatted-initials>M.M.</formatted-initials></name>
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
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="page">lxii</value><value type="page">500</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>Aluffi, P, DX Anderson, MS Hering, MM Mustaţă <em>et al.</em>, eds. (2022). <em>Facets of algebraic geometry: a collection in honor of william fulton's 80th birthday</em>, 1st edition. Cambridge, UK: CUP. DOI: 10.1017/9781108877831, 10.1017/9781108877832</formattedref>
    OUTPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em>{{ title | capitalize_first }}</em> [{{medium}}] ,_{{ edition }} .
      {{ place }} : {{ publisher_abbrev }} . {{ uri }}. At:_{{ access_location }}. DOI:_{{ doi | join: ", " }}
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: "" | remove: "." | remove: "_" }}, {{initials[1]  | join: "" | remove: "." | remove: "_" }} {{surname[1] }}, {{initials[2]  | join: "" | remove: "." | remove: "_" }} {{surname[2] }},  {{initials[3]  | join: "" | remove: "." | remove: "_" }} {{surname[3] }} <em>et al.</em>
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}",
                           etal_count: 4, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           language: "en",
           edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition",
           date: { month_year: "MMMd", day_month_year: "yMMMd",
                   date_time: "to_long_s" })
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "processes formatted initials" do
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
            <name><surname>Aluffi</surname><formatted-initials>D.-J. de X.</formatted-initials></name>
          </person>
        </contributor>
                <contributor>
          <role type="editor"/>
          <person>
            <name><surname>Anderson</surname><formatted-initials>D. X.</formatted-initials></name>
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
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="page">lxii</value><value type="page">500</value></size>
      </bibitem>
    INPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em>{{ title }}</em>.
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: " " | remove: "." }}, {{initials[1]  | join: " " | remove: "." }} {{surname[1] }}, {{initials[2]  | join: " " | remove: "." }} {{surname[2] }} <em>et al.</em>
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>Aluffi, D-J de X, D X Anderson, M S Hering <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           etal: etal })
    expect(p.render(input)).to be_equivalent_to output
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: "" }}, {{initials[1]  | join: "" }} {{surname[1] }}, {{initials[2]  | join: "" }} {{surname[2] }} <em>et al.</em>
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>Aluffi, D.-J.de X., D.X. Anderson, M.S. Hering <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           etal: etal })
    expect(p.render(input)).to be_equivalent_to output
  end

  it "processes underscore" do
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
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="page">lxii</value><value type="page">500</value></size>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, ed. (2022). <em><span class="std_class">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</span></em>, 1st edition. Cambridge, UK: CUP.</formattedref>
    OUTPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em><span_class="std\\_class">{{ title }}</span></em> [{{medium}}] ,_{{ edition }} .
      {{ place }} : {{ publisher_abbrev }} . {{ uri }}. At:_{{ access_location }}.
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { book: template }, language: "en")
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "processes selective filters" do
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
            <name><surname>Anderson</surname><formatted-initials>D. X.</formatted-initials></name>
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
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="page">lxii</value><value type="page">500</value></size>
      </bibitem>
    INPUT
    template = <<~TEMPLATE
      {{ creatornames | selective_upcase }} ,_{{role}} ({{date}}) . <em>{{ title }}</em>.
    TEMPLATE
    two = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: " " }} +++and+++ {{initials[1]  | join: " " | remove: "." }} {{surname[1] }}
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>ALUFFI, P. and D X ANDERSON, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           two: two })
    expect(p.render(input)).to be_equivalent_to output
    template = <<~TEMPLATE
      {{ creatornames | selective_tag: "<smallcap>" }} ,_{{role}} ({{date}}) . <em>{{ title }}</em>.
    TEMPLATE
    output = <<~OUTPUT
      <formattedref><smallcap>Aluffi, P. </smallcap>and<smallcap> D X Anderson</smallcap>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           two: two })
    expect(p.render(input)).to be_equivalent_to output
  end

  it "sanitises tags in bibliographic content" do
    input = <<~INPUT
      <bibitem type="book">
        <title>&lt;title&gt;Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday&lt;/title&gt;</title>
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
        <edition>1</edition>
        <series>
        <title>&lt;title&gt;London Mathematical Society Lecture Note Series&lt;/title&gt;</title>
        <number>472</number>
        </series>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
          <size><value type="page">lxii</value><value type="page">500</value></size>
      </bibitem>
    INPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em><title>{{ title }}</title></em> [{{medium}}] ,_{{ edition }} .
      {{ place }} : {{ publisher_abbrev }} . {{ uri }}. At:_{{ access_location }}.
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, ed. (2022). <em><title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title></em>, 1st edition. Cambridge, UK: CUP.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template }, language: "en")
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
      <formattedref>Aluffi, P., D. Anderson, M. S. Hering <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, 1st edition. Cambridge, UK.</formattedref>
    OUTPUT
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em>{{ title }}</em> [{{medium}}] ,_{{ edition }} .
      {{ place }}. {{ uri }}. At:_{{ access_location }}.
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: " " }}, {{initials[1]  | join: " " }} {{surname[1] }}, {{initials[2]  | join: " " }} {{surname[2] }} <em>et al.</em>
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { booklet: template, book: "booklet" },
           nametemplate: { one: "{{ nonpersonal[0] }}",
                           etal_count: 3, etal: etal },
           sizetemplate: "{{ page_raw }} pages",
           language: "en",
           edition_number: ["SpelloutRules", "spellout-ordinal"],
           edition: "% edition")
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "processes authorizer" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <edition>1</edition>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <contributor>
              <role type="authorizer"/>
              <organization>
                <name>The Illuminati</name>
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
      </bibitem>
    INPUT
    template = <<~TEMPLATE
      {{ authorizer }}
    TEMPLATE
    output = "<formattedref>The Illuminati</formattedref>"
    p = Relaton::Render::General
      .new(template: { book: template })
    expect(p.render(input))
      .to be_equivalent_to output

    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <edition>1</edition>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>Cambridge University Press</name>
                <abbreviation>CUP</abbreviation>
              </organization>
            </contributor>
            <place>Cambridge, UK</place>
      </bibitem>
    INPUT
    template = <<~TEMPLATE
      {{ authorizer }}
    TEMPLATE
    output = "<formattedref>Cambridge University Press</formattedref>"
    p = Relaton::Render::General
      .new(template: { book: template })
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
    output = <<~OUTPUT
      <formattedref>RAMSEY, J. K. and W. C. MCGREW. Object play in great apes: Studies in nature and captivity. In: PELLEGRINI, Anthony D. and Peter Kenneth SMITH (eds.): <em>The nature of play: Great apes and humans</em> [electronic resource, 8vo]. 3rd edition. New York, NY: Guilford Press. 2005. pp. 89&#x2013;112. [viewed: September 3, 2019].</formattedref>
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
                  <locality type="issue"><referenceFrom>7</referenceFrom></locality>
        <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
        </locality>
                </localityStack>
            </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. <em>London Mathematical Society Lecture Note Series</em> (N.S.). 1st edition. vol. 1 no. 7, pp. 89–112. Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
    expect(p.render(input.gsub(%r{</?localityStack>}m, "")))
      .to be_equivalent_to output
  end

  it "renders article with multiple extents" do
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
                  <locality type="volume"><referenceFrom>1</referenceFrom></locality>
                  <locality type="issue"><referenceFrom>7</referenceFrom></locality>
        <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
        </locality>
            </extent>
            <extent>
                  <locality type="issue"><referenceFrom>8</referenceFrom></locality>
        <locality type="page">
          <referenceFrom>90</referenceFrom>
        </locality>
            </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. <em>London Mathematical Society Lecture Note Series</em> (N.S.). 1st edition. vol. 1 no. 7, pp. 89–112; no. 8, p. 90. Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders article, with extended extent template incorporating year" do
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
                  <locality type="issue"><referenceFrom>7</referenceFrom></locality>
        <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
        </locality>
                </localityStack>
            </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, David ANDERSON, Milena HERING, Mircea MUSTAŢĂ and Sam PAYNE (eds.). Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. <em>London Mathematical Society Lecture Note Series</em> (N.S.). 1st edition. 1.7 (2022) 89–112. Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(
      extenttemplate: { article: <<~TEMPLATE,
        {{ volume_raw}}{%if issue %}.{{issue_raw}}{%endif%} ({{date}}) {{page_raw}}
      TEMPLATE
      },
    )
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders article, with journaltemplate" do
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
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <place>Paris</place>
        <organization>UCL</organization>
        <abbreviation>LMS</abbreviation>
        <from>1999</from>
        <to>2000</to>
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
                  <locality type="issue"><referenceFrom>7</referenceFrom></locality>
        <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
        </locality>
                </localityStack>
            </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo (ed.). Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. London Mathematical Society Lecture Note Series Paris UCL 1999–2000 N.S. 472. 1st edition. vol. 1 no. 7, pp. 89–112. Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(
      journaltemplate: <<~TEMPLATE,
        {{ series_title }} {{ series_place }} {{ series_org }} {{series_dates }} {{ series_run }} {{series_number}} {{series_partnumber }}
      TEMPLATE
    )
    expect(p.render(input))
      .to be_equivalent_to output

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
        <edition>1</edition>
        <series>
        <title>London Mathematical Society Lecture Note Series</title>
        <place>Paris</place>
        <organization>UCL</organization>
        <abbreviation>LMS</abbreviation>
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
                  <locality type="issue"><referenceFrom>7</referenceFrom></locality>
        <locality type="page">
          <referenceFrom>89</referenceFrom>
          <referenceTo>112</referenceTo>
        </locality>
                </localityStack>
            </extent>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo (ed.). Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. London Mathematical Society Lecture Note Series Paris UCL N.S. 472. 1st edition. vol. 1 no. 7, pp. 89–112. Cambridge, UK: Cambridge University Press. 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(
      journaltemplate: <<~TEMPLATE,
        {{ series_title }} {{ series_place }} {{ series_org }} {{series_dates }} {{ series_run }} {{series_number}} {{series_partnumber }}
      TEMPLATE
    )
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders software" do
    input = <<~INPUT
      <bibitem type="software">
        <title>metanorma-standoc</title>
        <uri>https://github.com/metanorma/metanorma-standoc</uri>
        <date type="published"><on>2019-09-04</on></date>
        <date type="accessed"><on>2023-08-31</on></date>
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
      <formattedref>Ribose Inc. <em>metanorma-standoc</em>. Version 1.3.1. 2019. <link target="https://github.com/metanorma/metanorma-standoc">https://github.com/metanorma/metanorma-standoc</link>. [viewed: August 31, 2023].</formattedref>
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
    INPUT
    output = <<~OUTPUT
      <formattedref>Internet Engineering Task Force. RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2. <link target="https://www.ietf.org/rfc/rfc3979.txt">https://www.ietf.org/rfc/rfc3979.txt</link>. [viewed: June 18, 2012].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders merged joint published standard" do
    input = <<~INPUT
      <bibitem type="standard">
        <title>Intellectual Property Rights in IETF technology</title>
        <uri>https://www.ietf.org/rfc/rfc3979.txt</uri>
        <uri>https://www.iso.org/rfc/rfc3979.txt</uri>
        <docidentifier primary="true" type="RFC">RFC 3979</docidentifier>
        <docidentifier primary="true" type="ISO">ISO 3979</docidentifier>
        <docidentifier type="ISO-committee">IC 3979</docidentifier>
        <docidentifier type="DOI">https://doi.org/10.3886/ICPSR20520.v2</docidentifier>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2012-06-18</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>Internet Engineering Task Force</name>
            <abbreviation>IETF</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
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
      <formattedref>BRADNER (ed.). RFC 3979|ISO 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. Internet Engineering Task Force and International Organization for Standardization. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2. <link target='https://www.ietf.org/rfc/rfc3979.txt'>https://www.ietf.org/rfc/rfc3979.txt</link>. [viewed: June 18, 2012].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders dual joint published standard" do
    input = <<~INPUT
      <bibitem type="standard">
        <title>Intellectual Property Rights in IETF technology</title>
        <uri>https://www.ietf.org/rfc/rfc3979.txt</uri>
        <docidentifier primary="true" type="RFC">RFC 3979</docidentifier>
        <docidentifier type="ISO-committee">IC 3979</docidentifier>
        <docidentifier type="DOI">https://doi.org/10.3886/ICPSR20520.v2</docidentifier>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2012-06-18</on></date>
        <contributor>
          <role type="publisher"/>
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
        <relation type="hasRepresentation">
              <bibitem type="standard">
        <title>Intellectual Property Rights in IETF technology</title>
        <uri>https://www.iso.org/rfc/rfc3979.txt</uri>
        <docidentifier primary="true" type="ISO">ISO 3979</docidentifier>
        <docidentifier type="ISO-committee">IC 3979</docidentifier>
        <docidentifier type="DOI">https://doi.org/10.3886/ICPSR20520.v2</docidentifier>
        <date type="published"><on>2005</on></date>
        <date type="accessed"><on>2012-06-18</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardisation</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        </bibitem>
        </relation>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref>BRADNER (ed.). RFC 3979: <em>Intellectual Property Rights in IETF technology</em>. Online. Internet Engineering Task Force. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2. <link target='https://www.ietf.org/rfc/rfc3979.txt'>https://www.ietf.org/rfc/rfc3979.txt</link>. [viewed: June 18, 2012]. Also published as: ISO 3979: <em>Intellectual Property Rights in IETF technology</em>. International Organization for Standardisation. 2005. DOI: https://doi.org/10.3886/ICPSR20520.v2. <link target='https://www.iso.org/rfc/rfc3979.txt'>https://www.iso.org/rfc/rfc3979.txt</link>. [viewed: June 18, 2012].</formattedref>
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
      <formattedref>PORTES, Alejandro and Rubén G. RUMBAUT. <em>Children of Immigrants. Longitudinal Sudy (CILS) 1991–2006 ICPSR20520</em>. Version 2. Dataset. 2012. <link target="https://doi.org/10.3886/ICPSR20520.v2">https://doi.org/10.3886/ICPSR20520.v2</link>. 501 GB. [viewed: May 6, 2018].</formattedref>
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
      <formattedref>LIBERMAN, Mark and Geoffrey PULLUM. <em>Language Log</em>. University of Pennsylvania. 2003&#x2013;. <link target="https://languagelog.ldc.upenn.edu/nll/">https://languagelog.ldc.upenn.edu/nll/</link>. [viewed: September 3, 2019].</formattedref>

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
      <formattedref>JENKINS and Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em>. Preprint. 2012. <link target="https://eprints.soton.ac.uk/338797/">https://eprints.soton.ac.uk/338797/</link>. [viewed: June 24, 2020].</formattedref>
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
      <formattedref>JENKINS and Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em>. 2012. <link target='https://eprints.soton.ac.uk/338797/'>https://eprints.soton.ac.uk/338797/</link>.</formattedref>
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
        <date type="published"><on>2020-06</on></date>
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
      <formattedref>JENKINS and Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em>. Preprint. 2020. <link target="https://eprints.soton.ac.uk/338797/">https://eprints.soton.ac.uk/338797/</link>. [viewed: June 2020].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "renders empty reference" do
    input = <<~INPUT
      <bibitem type="misc">
        <medium>
          <genre>preprint</genre>
        </medium>
      </bibitem>
    INPUT
    output = "<formattedref></formattedref>"
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "remove initial full stop" do
    input = <<~INPUT
      <bibitem type="misc">
        <title format='text/plain'>Cereals and cereal products</title>
        <medium>
          <genre>preprint</genre>
        </medium>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref><em>Cereals and cereal products</em>. n.d.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "does not insert no date for standards or websites" do
    input = <<~INPUT
      <bibitem type="standard">
        <title format='text/plain'>Cereals and cereal products</title>
        <medium>
          <genre>preprint</genre>
        </medium>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref><em>Cereals and cereal products</em>. Preprint.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
    input.sub!('type="standard"', 'type="website"')
    expect(p.render(input))
      .to be_equivalent_to output
    input.sub!('type="website"', 'type="book"')
    output = <<~OUTPUT
      <formattedref><em>Cereals and cereal products</em> [preprint]. n.p.: n.d.</formattedref>
    OUTPUT
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "picks right language and type for title" do
    input = <<~INPUT
      <bibitem type="misc">
        <title format='text/plain' type="alt" language="fr">Céréales et production céréalière 1</title>
        <title format='text/plain' type="main" language="fr">Céréales et production céréalière</title>
        <title format='text/plain' type="alt" language="de">Getreide und Getreideproduktion 1</title>
        <title format='text/plain' type="main" language="de">Getreide und Getreideproduktion</title>
        <medium>
          <genre>preprint</genre>
        </medium>
      </bibitem>
    INPUT
    output = <<~OUTPUT
      <formattedref><em>Getreide und Getreideproduktion</em>. o.J.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "de")
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "truncates date to year" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338791/</uri>
        <uri type="DOI">https://eprints.soton.ac.uk/338794/</uri>
        <uri type="DOI" language="de">https://eprints.soton.ac.uk/338795/</uri>
        <uri type="DOI" language="en">https://eprints.soton.ac.uk/338796/</uri>
        <date type="published"><on>2022-10-12</on></date>
        <date type="accessed"><on>2022-10-12</on></date>
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
      <formattedref>JENKINS and Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em> [preprint]. n.p.: 2022. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [viewed: October 12, 2022].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output

    input = <<~INPUT
      <bibitem type="book">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338791/</uri>
        <uri type="DOI">https://eprints.soton.ac.uk/338794/</uri>
        <uri type="DOI" language="de">https://eprints.soton.ac.uk/338795/</uri>
        <uri type="DOI" language="en">https://eprints.soton.ac.uk/338796/</uri>
        <date type="published"><from>2021-10-12</from><to>2022-10-12</to></date>
        <date type="accessed"><on>2022-10-12</on></date>
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
      <formattedref>JENKINS and Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em> [preprint]. n.p.: 2021–2022. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [viewed: October 12, 2022].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output

    input = <<~INPUT
      <bibitem type="book">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338791/</uri>
        <uri type="DOI">https://eprints.soton.ac.uk/338794/</uri>
        <uri type="DOI" language="de">https://eprints.soton.ac.uk/338795/</uri>
        <uri type="DOI" language="en">https://eprints.soton.ac.uk/338796/</uri>
        <date type="published"><from>2022-10-12</from><to>2022-11-12</to></date>
        <date type="accessed"><on>2022-10-12</on></date>
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
      <formattedref>JENKINS and Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em> [preprint]. n.p.: 2022. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [viewed: October 12, 2022].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end
end

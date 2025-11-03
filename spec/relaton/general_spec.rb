# encoding: utf-8

require_relative "../spec_helper"

RSpec.describe Relaton::Render do
  # rubocop:disable Layout/LineLength
  it "has a version number" do
    expect(Relaton::Render::VERSION).not_to be nil
  end

  it "parses a citation" do
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
        <status>valid</status>
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
    p = Relaton::Render::General.new
    data, = p.parse(input)
    hash = {
      authorcite: "<esc>Aluffi</esc>, <esc>Anderson</esc>, <esc>Hering</esc>, <esc>Mustaţă</esc> and <esc>Payne</esc>",
      authorizer: "Cambridge University Press",
      authorizer_raw: [{ nonpersonal: "Cambridge University Press" }],
      creatornames: "<esc>ALUFFI</esc>, Paolo, David Herbert <esc>ANDERSON</esc>, Milena Marie <esc>HERING</esc>, Mircea H. <esc>MUSTAŢĂ</esc> and Sam H. <esc>PAYNE</esc>",
      creators: [
        { given: "Paolo", initials: ["<esc>P.</esc>"], middle: [],
          surname: "<esc>Aluffi</esc>" }, { given: "David", initials: ["<esc>D.</esc>", "<esc>H.</esc>"], middle: ["Herbert"], surname: "<esc>Anderson</esc>" }, { given: "Milena Marie", initials: ["<esc>M.</esc>", "<esc>M.</esc>"], middle: [], surname: "<esc>Hering</esc>" }, { given: "Mircea", initials: ["<esc>M.</esc>", "<esc>H.</esc>"], middle: ["H."], surname: "<esc>Mustaţă</esc>" }, { given: "Sam H.", initials: ["<esc>S.</esc>", "<esc>H.</esc>"], middle: [], surname: "<esc>Payne</esc>" }
      ],
      date: "2022",
      doi: ["<esc>https://doi.org/10.1017/9781108877831</esc>"],
      draft: "draft ",
      draft_raw: { iteration: nil, status: "valid" },
      edition: "1st edition",
      edition_raw: "<esc>1</esc>",
      language: "en",
      other_identifier: ["DOI: https://doi.org/10.1017/9781108877831", "ISBN: 9781108877831"],
      other_identifier_raw: [["DOI", "https://doi.org/10.1017/9781108877831"], ["ISBN", "9781108877831"]],
      publisher: "Cambridge University Press",
      publisher_abbrev: "Cambridge University Press",
      publisher_abbrev_raw: ["Cambridge University Press"],
      publisher_raw: [{ nonpersonal: "Cambridge University Press" }],
      role: "eds.",
      role_raw: "editor",
      script: "Latn",
      series: "<esc>London Mathematical Society Lecture Note Series</esc> 472",
      series_num: "472",
      series_title: "<esc>London Mathematical Society Lecture Note Series</esc>",
      size: "1 vol.",
      size_raw: { "volume" => ["1"] },
      status: "Valid",
      status_raw: "valid",
      title: "<esc>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</esc>",
      type: "book",
    }
    expect(metadata(data)).to eq(hash)

    hash[:language] = "ja"
    hash[:script] = "Jpan"
    data, = p.parse(input
      .sub("</edition>",
           "</edition><language>ja</language><script>Jpan</script><locale>JP</locale>"))
    expect(metadata(data)).to eq(hash)
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

  it "outputs config" do
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
    output = {
      "authorcitetemplate" => {
        "more" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] }}{% endif %}, {% if nonpersonal[1] %}{{ nonpersonal[1] }}{% else %}{{surname[1] }}{% endif %} {{ labels['author_and'] }} {% if nonpersonal[2] %}{{ nonpersonal[2] }}{% else %}{{surname[2] }}{% endif %}", "one" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] }}{% endif %}", "two" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] }}{% endif %} {{ labels['author_and'] }} {% if nonpersonal[1] %}{{ nonpersonal[1] }}{% else %}{{surname[1] }}{% endif %}"
      },
      "citetemplate" => { "author" => "{{ author }}",
                          "author_date" => "{{ author }} {{ date}}", "author_date_br" => "{{ author }} ({{ date}})", "date" => "{{ date }}", "reference_tag" => "{{ biblio_tag }}", "short" => { "alert" => "misc", "archival" => "misc", "article" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-secondary-title']}}{{ title }}{{labels['punct']['close-secondary-title']}}$$$ {{ series }} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ {{size}}$$$ {{ extent }}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "audiovisual" => "misc", "book" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ ({{ series }}$$$|) {% if place %}{{place}}{%else%}{{ labels['no_place']}}{%endif%}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{size}}$$$ {{extent}}$$$", "booklet" => "book", "broadcast" => "misc", "conversation" => "misc", "dataset" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize }}$$$ {{ labels['in'] | capitalize }}:_{{series}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ size }}$$$ {{ extent}}$$$", "electronic resource" => "software", "film" => "misc", "graphic_work" => "misc", "inbook" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-secondary-title']}}{{ title }}{{labels['punct']['close-secondary-title']}} $$$ {{ labels['in'] | capitalize }}: {{ host_creatornames}} ({{ host_role}}) : {{labels['punct']['open-title']}}{{host_title}}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ ({{ series }}$$$|) {% if place %}{{place}}{%else%}{{ labels['no_place']}}{%endif%}: {{publisher}}$$$ {{date}}$$$ {{size}}$$$ {{extent}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "incollection" => "inbook", "inproceedings" => "inbook", "internal" => "misc", "journal" => "{{labels['punct']['open-title']}}{{ title}}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{size}}$$$ {{extent}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "manual" => "book", "map" => "misc", "message" => "misc", "misc" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ date }}$$$", "music" => "misc", "patent" => "misc", "performance" => "misc", "proceedings" => "book", "social_media" => "misc", "software" => "{{ creatornames }} ({{ role}}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize}}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{size}}$$$ {{ extent}}$$$", "standard" => "{{ creatornames }} ({{ role}}) $$$ {{ authoritative_identifier | join: '|' }}: {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ edition | capitalize_first }}$$$ {{ place }}: {{ publisher }}$$$ {{date}}$$$ {{size}}$$$ {{ extent }}$$$ {{ other_identifier | join: '$$$ ' }}", "techreport" => "standard", "thesis" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ place }}: {{ publisher }}$$$ {{ date }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "unpublished" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ date }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$  {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "video" => "misc", "webresource" => "website", "website" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize }}$$$ {{ place }}: {{ publisher }}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$" }, "title" => "{{ title }}", "title_reference_tag" => "{{ title }} {{ biblio_tag }}" },
      "extenttemplate" => {
        "article" => "{{ volume }} {{issue}} , {{ page }}, {{ duration }}", "book" => "{{ volume }}, {{ page }}", "booklet" => "book", "inbook" => "{{ volume }}: {{ page }}", "journal" => "book", "misc" => "{{ volume }} {{issue}} , {{ page }}, {{ duration }}", "proceedings" => "book", "standard" => "book", "techreport" => "book"
      },
      "journaltemplate" => "<em>{% if series_abbr %}{{series_abbr}}{% else %}{{series_title}}{% endif %}</em> ({{series_run}}) {{ labels['volume'] }}_{{series_num}} {{ labels['part'] }}_{{series_partnumber}}",
      "language" => "en",
      "nametemplate" => {
        "more" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] | upcase}} ,_{%if given[0]%}{{given[0]}} {{middle[0]}}{%else%}{{initials[0] | join: ' '}}.{%endif%}{% endif %} , {% if nonpersonal[1] %}{{ nonpersonal[1] }}{% else %}{%if given[1]%}{{given[1]}} {{middle[1]}}{%else%}{{initials[1] | join: ' '}}.{%endif%} {{surname[1] | upcase}}{% endif %} {{ labels['author_and'] }} {% if nonpersonal[2] %}{{ nonpersonal[2] }}{% else %}{%if given[2]%}{{given[2]}} {{middle[2]}}{%else%}{{initials[2] | join: ' '}}.{%endif%} {{surname[2] | upcase}}{% endif %}", "one" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] | upcase }} ,_{%if given[0]%}{{given[0]}} {{middle[0]}}{%else%}{{initials[0] | join: ' '}}.{%endif%}{% endif %}", "two" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] | upcase}} ,_{%if given[0]%}{{given[0]}} {{middle[0]}}{%else%}{{initials[0] | join: ' '}}.{%endif%}{% endif %} {{ labels['author_and'] }} {% if nonpersonal[1] %}{{ nonpersonal[1] }}{% else %}{%if given[1]%}{{given[1]}} {{middle[1]}}{%else%}{{initials[1] | join: ' '}}.{%endif%} {{surname[1] | upcase}}{% endif %}"
      },
      "script" => "Latn",
      "seriestemplate" => "{% if series_formatted %}{{ series_formatted }}{%else%}{% if series_abbr %}{{series_abbr}}{% else %}{{series_title}}{% endif %} ({{series_run}}) {{series_num}}|({{series_partnumber}}){%endif%}",
      "sizetemplate" => { "dataset" => "{{ data }}",
                          "electronic resource" => "dataset", "misc" => "{{ volume }}, {{ issue }}, {{ page }}, {{ data }}, {{ duration }}", "webresource" => "dataset" },
      "template" => { "alert" => "misc", "archival" => "misc",
                      "article" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-secondary-title']}}{{ title }}{{labels['punct']['close-secondary-title']}}$$$ {{ series }} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ {{size}}$$$ {{ extent }}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "audiovisual" => "misc", "book" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ ({{ series }}$$$|) {% if place %}{{place}}{%else%}{{ labels['no_place']}}{%endif%}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$ {{size}}$$$ {{extent}}$$$", "booklet" => "book", "broadcast" => "misc", "conversation" => "misc", "dataset" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize }}$$$ {{ labels['in'] | capitalize }}:_{{series}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ size }}$$$ {{ extent}}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$ ", "electronic resource" => "software", "film" => "misc", "graphic_work" => "misc", "inbook" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-secondary-title']}}{{ title }}{{labels['punct']['close-secondary-title']}} $$$ {{ labels['in'] | capitalize }}: {{ host_creatornames}} ({{ host_role}}) : {{labels['punct']['open-title']}}{{host_title}}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ ({{ series }}$$$|) {% if place %}{{place}}{%else%}{{ labels['no_place']}}{%endif%}: {{publisher}}$$$ {{date}}$$$ {{size}}$$$ {{extent}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "incollection" => "inbook", "inproceedings" => "inbook", "internal" => "misc", "journal" => "{{labels['punct']['open-title']}}{{ title}}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{size}}$$$ {{extent}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "manual" => "book", "map" => "misc", "message" => "misc", "misc" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ date }}$$$ {{ uri }}$$$", "music" => "misc", "patent" => "misc", "performance" => "misc", "presentation" => "unpublished", "proceedings" => "book", "social_media" => "misc", "software" => "{{ creatornames }} ({{ role}}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize}}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{size}}$$$ {{ extent}}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$ ", "standard" => "{{ creatornames }} ({{ role}}) $$$ {{ authoritative_identifier | join: '|' }}: {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ edition | capitalize_first }}$$$ {{ place }}: {{ publisher }}$$$ {{date}}$$$ {{size}}$$$ {{ extent }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "techreport" => "standard", "thesis" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ place }}: {{ publisher }}$$$ {{ date }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "unpublished" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ date }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$  {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "video" => "misc", "webresource" => "website", "website" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize }}$$$ {{ place }}: {{ publisher }}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$ " },
    }
    expect(p.config)
      .to eq output
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
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em>{{ title | capitalize_first }}</em> [{{medium}}] ,_{{ edition }} .
      {{ place }} : {{ publisher_abbrev }} . {{ uri }}. At:_{{ access_location }}. DOI:_{{ doi | join: ", " }}
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: "" | remove: "." | remove: "_" }}, {{initials[1]  | join: "" | remove: "." | remove: "_" }} {{surname[1] }}, {{initials[2]  | join: "" | remove: "." | remove: "_" }} {{surname[2] }},  {{initials[3]  | join: "" | remove: "." | remove: "_" }} {{surname[3] }} <em>et al.</em>
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>Aluffi, P, DX Anderson, MS Hering, MM Mustaţă <em>et al.</em>, eds. (2022). <em>Facets of algebraic geometry: a collection in honor of william fulton's 80th birthday</em>, 1st edition. Cambridge, UK: CUP. DOI: 10.1017/9781108877831, 10.1017/9781108877832.</formattedref>
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
  end

  it "processes capitalize_first with XML tags" do
    # Test with XML tags at the beginning - should capitalize first word, not tag
    input1 = <<~INPUT
      <bibitem type="book">
        <title>hello, dolly</title>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Test</surname><forename>Author</forename></name>
          </person>
        </contributor>
      </bibitem>
    INPUT
    template = <<~TEMPLATE
      {{ creatornames }}. <em>{{ title | capitalize_first }}</em>. {{ place }}: {{ publisher }}. {{date}}.
    TEMPLATE
    output1 = <<~OUTPUT
      <formattedref>TEST, Author. <em>Hello, dolly</em>. 2022.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(template: { book: template },
                                     language: "en")
    expect(p.render(input1)).to be_equivalent_to output1

    # Title, which is rendered with <esc> tags, respects them under i18n
    output1 = <<~OUTPUT
      <formattedref>TEST, Author. <em>Hello, dolly</em>. 2022.。</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(template: { book: template },
                                     language: "ja")
    expect(p.render(input1)).to be_equivalent_to output1

    # Test with multiple tags
    input2 = <<~INPUT
      <bibitem type="book">
        <title><em><strong>test</strong></em> word</title>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Test</surname><forename>Author</forename></name>
          </person>
        </contributor>
      </bibitem>
    INPUT
    output2 = <<~OUTPUT
      <formattedref>TEST, Author. <em><em><strong>Test</strong></em> word</em>. 2022.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(template: { book: template },
                                     language: "en")
    expect(p.render(input2)).to be_equivalent_to output2

    # Test with leading spaces before tag
    input3 = <<~INPUT
      <bibitem type="book">
        <title>  <tag>hello world</tag></title>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Test</surname><forename>Author</forename></name>
          </person>
        </contributor>
      </bibitem>
    INPUT
    output3 = <<~OUTPUT
      <formattedref>TEST, Author. <em><tag>Hello world</tag></em>. 2022.</formattedref>
    OUTPUT
    expect(p.render(input3)).to be_equivalent_to output3

    # Test with underscores before tag
    input4 = <<~INPUT
      <bibitem type="book">
        <title>_<tag>hello world</tag></title>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Test</surname><forename>Author</forename></name>
          </person>
        </contributor>
      </bibitem>
    INPUT
    output4 = <<~OUTPUT
      <formattedref>TEST, Author. <em>_<tag>hello world</tag></em>. 2022.</formattedref>
    OUTPUT
    expect(p.render(input4)).to be_equivalent_to output4

    # Test without tags - backward compatibility
    input5 = <<~INPUT
      <bibitem type="book">
        <title>hello world</title>
        <date type="published"><on>2022</on></date>
        <contributor>
          <role type="author"/>
          <person>
            <name><surname>Test</surname><forename>Author</forename></name>
          </person>
        </contributor>
      </bibitem>
    INPUT
    output5 = <<~OUTPUT
      <formattedref>TEST, Author. <em>Hello world</em>. 2022.</formattedref>
    OUTPUT
    expect(p.render(input5)).to be_equivalent_to output5
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
      {{ creatornames }} ,_{{role}} ({{date}}) $$$ <em>{{ title }}</em>.
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

    template = <<~TEMPLATE
      {{ creatornames }}$$$ ({{date}}) $$$ <em>{{ title }}</em>.
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>Aluffi, D.-J.de X., D.X. Anderson, M.S. Hering <em>et al</em>. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           etal: etal })
    expect(p.render(input)).to be_equivalent_to output

    output = <<~OUTPUT
      <formattedref>Aluffi, D.-J.de X., D.X. Anderson, M.S. Hering <em>et al.</em>, (2022), <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           etal: etal },
           "i18nhash" => {
             "punct" => {
               "biblio-field-delimiter" => ", ",
             },
           })
    expect(p.render(input)).to be_equivalent_to output

    output = <<~OUTPUT
      <formattedref>Aluffi, D.-J.de X., D.X. Anderson, M.S. Hering <em>et al</em>. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           etal: etal },
           "i18nhash" => {
             "punct" => {
               "biblio-field-delimiter" => "<esc>.</esc> ",
             },
           })
    expect(p.render(input)).to be_equivalent_to output
  end

  it "strips space from biblio-field-delimiter" do
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
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) $$$ “{{ title }}$$$”
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, ed. (2022). “Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday. ”.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template }, language: "en")
    expect(p.render(input))
      .to be_equivalent_to output

    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) $$$ “{{ title }}$$$|”
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, ed. (2022). “Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday.”.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template }, language: "en")
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "processes linking punctuation to potentially empty fields" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN">9781108877831</docidentifier>
        <date type="published"><on>2022</on></date>
        <date type="accessed"><on>2022-04-02</on></date>
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
      {{ title }} $$$ {{ place }} : {{ publisher_abbrev }} $$$ {{ date }}
    TEMPLATE
    input_no_place = input.sub(%r{<place>.+</place>}, "")
    input_no_pub = input.sub(%r{<contributor>.+</contributor>}m, "")
    input_no_pub_no_place = input.sub(%r{<contributor>.+</contributor>}m, "")
      .sub(%r{<place>.+</place>}, "")
    p = Relaton::Render::General
      .new(template: { book: template }, language: "en")
    expect(p.render(input))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. Cambridge, UK: CUP. 2022.</formattedref>"
    expect(p.render(input_no_place))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. : CUP. 2022.</formattedref>"
    expect(p.render(input_no_pub))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. Cambridge, UK. 2022.</formattedref>"
    expect(p.render(input_no_pub_no_place))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. 2022.</formattedref>"

    template = <<~TEMPLATE
      {{ title }} $$$ {{ place }}: {{ publisher_abbrev }} $$$ {{ date }}
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { book: template }, language: "en")
    expect(p.render(input))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. Cambridge, UK: CUP. 2022.</formattedref>"
    expect(p.render(input_no_place))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. CUP. 2022.</formattedref>"
    expect(p.render(input_no_pub))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. Cambridge, UK. 2022.</formattedref>"
    expect(p.render(input_no_pub_no_place))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. 2022.</formattedref>"

    template = <<~TEMPLATE
      {{ title }} $$$ {{ place }} :_{{ publisher_abbrev }} $$$ {{ date }}
    TEMPLATE
    p = Relaton::Render::General
      .new(template: { book: template }, language: "en")
    expect(p.render(input))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. Cambridge, UK: CUP. 2022.</formattedref>"
    expect(p.render(input_no_place))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. : CUP. 2022.</formattedref>"
    expect(p.render(input_no_pub))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. Cambridge, UK. 2022.</formattedref>"
    expect(p.render(input_no_pub_no_place))
      .to be_equivalent_to "<formattedref>Facets of Algebraic Geometry. 2022.</formattedref>"
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
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em><span_class="std\\_class">{{ title }}</span></em> [{{medium}}] ,_{{ edition }} .
      {{ place }} : {{ publisher_abbrev }} . {{ uri }}. At:_{{ access_location }}.
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>ALUFFI, Paolo, ed. (2022). <em><span class="std_class">Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</span></em>, 1st edition. Cambridge, UK: CUP.</formattedref>
    OUTPUT
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

  it "processes selective_upcase with XML tags" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Facets of Algebraic Geometry</title>
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
            <name><surname>Anderson</surname><formatted-initials>D. X.</formatted-initials></name>
          </person>
        </contributor>
      </bibitem>
    INPUT

    # Test with XML tags - should preserve tags while uppercasing text
    template = <<~TEMPLATE
      {{ creatornames | selective_upcase }} ,_{{role}} ({{date}}) . <em>{{ title }}</em>.
    TEMPLATE
    two = <<~TEMPLATE
      {{surname[0] }}, <tag>{{initials[0] | join: " " }}</tag> +++and+++ {{initials[1]  | join: " " | remove: "." }} {{surname[1] }}
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>ALUFFI, <tag>P. </tag> and D X ANDERSON, eds. (2022). <em>Facets of Algebraic Geometry</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           two: two })
    expect(p.render(input)).to be_equivalent_to output

    # Test with multiple XML tags
    two = <<~TEMPLATE
      <em>{{surname[0] }}</em>, {{initials[0] | join: " " }} +++and+++ <strong>{{initials[1]  | join: " " | remove: "." }}</strong> {{surname[1] }}
    TEMPLATE
    output = <<~OUTPUT
      <formattedref><em>ALUFFI</em>, P. and <strong>D X</strong> ANDERSON, eds. (2022). <em>Facets of Algebraic Geometry</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           two: two })
    expect(p.render(input)).to be_equivalent_to output

    # Test with nested XML tags
    two = <<~TEMPLATE
      {{surname[0] }}, <outer><inner>{{initials[0] | join: " " }}</inner></outer> +++and+++ {{initials[1]  | join: " " | remove: "." }} {{surname[1] }}
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>ALUFFI, <outer><inner>P. </inner></outer> and D X ANDERSON, eds. (2022). <em>Facets of Algebraic Geometry</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           two: two })
    expect(p.render(input)).to be_equivalent_to output

    # Test without +++ markers - should upcase all text but preserve XML tags
    two = <<~TEMPLATE
      {{surname[0] }}, <tag>{{initials[0] | join: " " }}</tag> and {{initials[1]  | join: " " | remove: "." }} {{surname[1] }}
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>ALUFFI, <tag>P. </tag> AND D X ANDERSON, eds. (2022). <em>Facets of Algebraic Geometry</em>.</formattedref>
    OUTPUT
    p = Relaton::Render::General
      .new(template: { book: template },
           nametemplate: { one: "{{ nonpersonal[0] }}", etal_count: 3,
                           two: two })
    expect(p.render(input)).to be_equivalent_to output

    # Test backward compatibility without XML tags
    two = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: " " }} +++and+++ {{initials[1]  | join: " " | remove: "." }} {{surname[1] }}
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>ALUFFI, P. and D X ANDERSON, eds. (2022). <em>Facets of Algebraic Geometry</em>.</formattedref>
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
    template = <<~TEMPLATE
      {{ creatornames }} ,_{{role}} ({{date}}) . <em>{{ title }}</em> [{{medium}}] ,_{{ edition }} .
      {{ place }}. {{ uri }}. At:_{{ access_location }}.
    TEMPLATE
    etal = <<~TEMPLATE
      {{surname[0] }}, {{initials[0] | join: " " }}, {{initials[1]  | join: " " }} {{surname[1] }}, {{initials[2]  | join: " " }} {{surname[2] }} <em>et al.</em>
    TEMPLATE
    output = <<~OUTPUT
      <formattedref>Aluffi, P., D. Anderson, M. S. Hering <em>et al.</em>, eds. (2022). <em>Facets of Algebraic Geometry: A Collection in Honor of William Fulton's 80th Birthday</em>, 1st edition. Cambridge, UK.</formattedref>
    OUTPUT
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

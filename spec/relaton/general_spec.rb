# encoding: utf-8

require_relative "../spec_helper"

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
       "authorcitetemplate" => {"more" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] }}{% endif %}, {% if nonpersonal[1] %}{{ nonpersonal[1] }}{% else %}{{surname[1] }}{% endif %} {{ labels['author_and'] }} {% if nonpersonal[2] %}{{ nonpersonal[2] }}{% else %}{{surname[2] }}{% endif %}", "one" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] }}{% endif %}", "two" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] }}{% endif %} {{ labels['author_and'] }} {% if nonpersonal[1] %}{{ nonpersonal[1] }}{% else %}{{surname[1] }}{% endif %}"},
       "citetemplate" => {"author" => "{{ author }}", "author_date" => "{{ author }} {{ date}}", "author_date_br" => "{{ author }} ({{ date}})", "date" => "{{ date }}", "reference_tag" => "{{ biblio_tag }}", "short" => {"alert" => "misc", "archival" => "misc", "article" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-secondary-title']}}{{ title }}{{labels['punct']['close-secondary-title']}}$$$ {{ series }} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ {{size}}$$$ {{ extent }}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "audiovisual" => "misc", "book" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ ({{ series }}$$$|) {% if place %}{{place}}{%else%}{{ labels['no_place']}}{%endif%}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{size}}$$$ {{extent}}$$$", "booklet" => "book", "broadcast" => "misc", "conversation" => "misc", "dataset" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize }}$$$ {{ labels['in'] | capitalize }}:_{{series}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ size }}$$$ {{ extent}}$$$", "electronic resource" => "software", "film" => "misc", "graphic_work" => "misc", "inbook" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-secondary-title']}}{{ title }}{{labels['punct']['close-secondary-title']}} $$$ {{ labels['in'] | capitalize }}: {{ host_creatornames}} ({{ host_role}}) : {{labels['punct']['open-title']}}{{host_title}}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ ({{ series }}$$$|) {% if place %}{{place}}{%else%}{{ labels['no_place']}}{%endif%}: {{publisher}}$$$ {{date}}$$$ {{size}}$$$ {{extent}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "incollection" => "inbook", "inproceedings" => "inbook", "internal" => "misc", "journal" => "{{labels['punct']['open-title']}}{{ title}}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{size}}$$$ {{extent}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "manual" => "book", "map" => "misc", "message" => "misc", "misc" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ date }}$$$", "music" => "misc", "patent" => "misc", "performance" => "misc", "proceedings" => "book", "social_media" => "misc", "software" => "{{ creatornames }} ({{ role}}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize}}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{size}}$$$ {{ extent}}$$$", "standard" => "{{ creatornames }} ({{ role}}) $$$ {{ authoritative_identifier | join: '|' }}: {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ edition | capitalize_first }}$$$ {{ place }}: {{ publisher }}$$$ {{date}}$$$ {{size}}$$$ {{ extent }}$$$ {{ other_identifier | join: '$$$ ' }}", "techreport" => "standard", "thesis" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ place }}: {{ publisher }}$$$ {{ date }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "unpublished" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ date }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$  {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$", "video" => "misc", "webresource" => "website", "website" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize }}$$$ {{ place }}: {{ publisher }}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$"}, "title" => "{{ title }}", "title_reference_tag" => "{{ title }} {{ biblio_tag }}"},
       "extenttemplate" => {"article" => "{{ volume }} {{issue}} , {{ page }}, {{ duration }}", "book" => "{{ volume }}, {{ page }}", "booklet" => "book", "inbook" => "{{ volume }}: {{ page }}", "journal" => "book", "misc" => "{{ volume }} {{issue}} , {{ page }}, {{ duration }}", "proceedings" => "book", "standard" => "book", "techreport" => "book"},
       "journaltemplate" => "<em>{% if series_abbr %}{{series_abbr}}{% else %}{{series_title}}{% endif %}</em> ({{series_run}}) {{ labels['volume'] }}_{{series_num}} {{ labels['part'] }}_{{series_partnumber}}",
       "language" => "en",
       "nametemplate" => {"more" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] | upcase}} ,_{%if given[0]%}{{given[0]}} {{middle[0]}}{%else%}{{initials[0] | join: ' '}}.{%endif%}{% endif %} , {% if nonpersonal[1] %}{{ nonpersonal[1] }}{% else %}{%if given[1]%}{{given[1]}} {{middle[1]}}{%else%}{{initials[1] | join: ' '}}.{%endif%} {{surname[1] | upcase}}{% endif %} {{ labels['author_and'] }} {% if nonpersonal[2] %}{{ nonpersonal[2] }}{% else %}{%if given[2]%}{{given[2]}} {{middle[2]}}{%else%}{{initials[2] | join: ' '}}.{%endif%} {{surname[2] | upcase}}{% endif %}", "one" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] | upcase }} ,_{%if given[0]%}{{given[0]}} {{middle[0]}}{%else%}{{initials[0] | join: ' '}}.{%endif%}{% endif %}", "two" => "{% if nonpersonal[0] %}{{ nonpersonal[0] }}{% else %}{{surname[0] | upcase}} ,_{%if given[0]%}{{given[0]}} {{middle[0]}}{%else%}{{initials[0] | join: ' '}}.{%endif%}{% endif %} {{ labels['author_and'] }} {% if nonpersonal[1] %}{{ nonpersonal[1] }}{% else %}{%if given[1]%}{{given[1]}} {{middle[1]}}{%else%}{{initials[1] | join: ' '}}.{%endif%} {{surname[1] | upcase}}{% endif %}"},
       "script" => "Latn",
       "seriestemplate" => "{% if series_formatted %}{{ series_formatted }}{%else%}{% if series_abbr %}{{series_abbr}}{% else %}{{series_title}}{% endif %} ({{series_run}}) {{series_num}}|({{series_partnumber}}){%endif%}",
       "sizetemplate" => {"dataset" => "{{ data }}", "electronic resource" => "dataset", "misc" => "{{ volume }}, {{ issue }}, {{ page }}, {{ data }}, {{ duration }}", "webresource" => "dataset"},
       "template" => {"alert" => "misc", "archival" => "misc", "article" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-secondary-title']}}{{ title }}{{labels['punct']['close-secondary-title']}}$$$ {{ series }} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ {{size}}$$$ {{ extent }}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "audiovisual" => "misc", "book" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ ({{ series }}$$$|) {% if place %}{{place}}{%else%}{{ labels['no_place']}}{%endif%}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$ {{size}}$$$ {{extent}}$$$", "booklet" => "book", "broadcast" => "misc", "conversation" => "misc", "dataset" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize }}$$$ {{ labels['in'] | capitalize }}:_{{series}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ size }}$$$ {{ extent}}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$ ", "electronic resource" => "software", "film" => "misc", "graphic_work" => "misc", "inbook" => "{{ creatornames }} ({{role}}) $$$ {{labels['punct']['open-secondary-title']}}{{ title }}{{labels['punct']['close-secondary-title']}} $$$ {{ labels['in'] | capitalize }}: {{ host_creatornames}} ({{ host_role}}) : {{labels['punct']['open-title']}}{{host_title}}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ ({{ series }}$$$|) {% if place %}{{place}}{%else%}{{ labels['no_place']}}{%endif%}: {{publisher}}$$$ {{date}}$$$ {{size}}$$$ {{extent}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "incollection" => "inbook", "inproceedings" => "inbook", "internal" => "misc", "journal" => "{{labels['punct']['open-title']}}{{ title}}{{labels['punct']['close-title']}} [{{medium}}] $$$ {{ edition | capitalize_first }}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{size}}$$$ {{extent}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "manual" => "book", "map" => "misc", "message" => "misc", "misc" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ date }}$$$ {{ uri }}$$$", "music" => "misc", "patent" => "misc", "performance" => "misc", "presentation" => "unpublished", "proceedings" => "book", "social_media" => "misc", "software" => "{{ creatornames }} ({{ role}}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize}}$$$ {{place}}: {{publisher}}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{size}}$$$ {{ extent}}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$ ", "standard" => "{{ creatornames }} ({{ role}}) $$$ {{ authoritative_identifier | join: '|' }}: {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ edition | capitalize_first }}$$$ {{ place }}: {{ publisher }}$$$ {{date}}$$$ {{size}}$$$ {{ extent }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "techreport" => "standard", "thesis" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ place }}: {{ publisher }}$$$ {{ date }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "unpublished" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ medium | capitalize }}$$$ {{ date }}$$$ {{ labels['at'] | capitalize}}:_{{ access_location }}$$$  {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$", "video" => "misc", "webresource" => "website", "website" => "{{ creatornames }} ({{ role }}) $$$ {{labels['punct']['open-title']}}{{ title }}{{labels['punct']['close-title']}} $$$ {{ labels['version'] | capitalize }}_{{ edition_raw }}$$$ {{medium | capitalize }}$$$ {{ place }}: {{ publisher }}$$$ {{date}}$$$ {{ labels['updated'] | capitalize }}:_{{date_updated}}$$$ {{ authoritative_identifier | join: '$$$ ' }}$$$ {{ other_identifier | join: '$$$ ' }}$$$ {{ uri }}$$$ [{{ labels['viewed'] }}:_{{date_accessed}}]$$$ "},    }
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
    output = <<~OUTPUT
      <formattedref>Aluffi, P, DX Anderson, MS Hering, MM Mustaţă <em>et al.</em>, eds. (2022). <em>Facets of algebraic geometry: a collection in honor of william fulton's 80th birthday</em>, 1st edition. Cambridge, UK: CUP. DOI: 10.1017/9781108877831, 10.1017/9781108877832.</formattedref>
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

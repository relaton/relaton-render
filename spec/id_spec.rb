# encoding: utf-8

require "spec_helper"

RSpec.describe Relaton::Render do
  it "ignore non-authoritative identifiers" do
    input = <<~INPUT
      <bibitem id="ref_pddl" type="book" schema-version="v1.2.4">
      <fetched>2023-09-29</fetched>
      <title type="main" format="text/plain" script="Latn">An Introduction to the Planning Domain Definition Language</title>
      <docidentifier type="DOI" primary="true">10.1007/978-3-031-01584-7</docidentifier>
      <docidentifier type="ISO" primary="true">ISO 123</docidentifier>
      <docidentifier type="metanorma-ordinal">[B1]</docidentifier>
      <docidentifier type="ISBN">9783031004568</docidentifier>
      <docidentifier type="ISBN">9783031015847</docidentifier>
      <docidentifier type="issn.print">1939-4608</docidentifier>
      <docidentifier type="issn.electronic">1939-4616</docidentifier>
      </bibitem>
    INPUT
    p = Relaton::Render::General.new
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["ISO 123"]

    input = <<~INPUT
      <bibitem id="ref_pddl" type="book" schema-version="v1.2.4">
      <fetched>2023-09-29</fetched>
      <title type="main" format="text/plain" script="Latn">An Introduction to the Planning Domain Definition Language</title>
      <docidentifier type="DOI" primary="true">10.1007/978-3-031-01584-7</docidentifier>
      <docidentifier type="metanorma-ordinal">[B1]</docidentifier>
      <docidentifier type="ISBN">9783031004568</docidentifier>
      <docidentifier type="ISBN">9783031015847</docidentifier>
      <docidentifier type="issn.print">1939-4608</docidentifier>
      <docidentifier type="issn.electronic">1939-4616</docidentifier>
      </bibitem>
    INPUT
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq []
  end

  it "ignores identifiers in the wrong language" do
    input = <<~INPUT
      <bibitem id="ref_pddl" type="book" schema-version="v1.2.4">  <fetched>2023-09-29</fetched>
      <title type="main" format="text/plain" script="Latn">An Introduction to the Planning Domain Definition Language</title>
      <docidentifier type="BIPM" language="en">A</docidentifier>
      <docidentifier type="BIPM" language="fr">B</docidentifier>
      <docidentifier type="BIPM">C</docidentifier>
      </bibitem>
    INPUT
    p = Relaton::Render::General.new(language: "en")
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["A"]
    p = Relaton::Render::General.new(language: "fr")
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["B"]
    p = Relaton::Render::General.new(language: "de")
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["A", "B", "C"]

    input = <<~INPUT
      <bibitem id="ref_pddl" type="book" schema-version="v1.2.4">  <fetched>2023-09-29</fetched>
      <title type="main" format="text/plain" script="Latn">An Introduction to the Planning Domain Definition Language</title>
      <docidentifier type="BIPM" language="en">A</docidentifier>
      <docidentifier type="BIPM" primary="true" language="fr">B</docidentifier>
      <docidentifier type="BIPM" primary="true" language="de">C</docidentifier>
      </bibitem>
    INPUT
    p = Relaton::Render::General.new(language: "en")
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["B", "C"]
    p = Relaton::Render::General.new(language: "fr")
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["B"]
    p = Relaton::Render::General.new(language: "de")
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["C"]
  end

  it "ignore untrademarked IEEE identifiers" do
    input = <<~INPUT
        <bibitem id="ref_pddl" type="book" schema-version="v1.2.4">  <fetched>2023-09-29</fetched>
      <title type="main" format="text/plain" script="Latn">An Introduction to the Planning Domain Definition Language</title>
        <docidentifier type="DOI">10.1007/978-3-031-01584-7</docidentifier>
        <docidentifier type="IEEE" scope="trademark">IEEE-TM 2</docidentifier>
        <docidentifier type="IEEE">IEEE 2</docidentifier>
        </bibitem>
    INPUT
    p = Relaton::Render::General.new
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["IEEE-TM 2"]

    input.sub!(
      '<docidentifier type="IEEE" scope="trademark">IEEE-TM 2</docidentifier>',
      "",
    )
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["IEEE 2"]
  end

  it "ignore non-IEEE scopes" do
    input = <<~INPUT
        <bibitem id="ref_pddl" type="book" schema-version="v1.2.4">  <fetched>2023-09-29</fetched>
      <title type="main" format="text/plain" script="Latn">An Introduction to the Planning Domain Definition Language</title>
        <docidentifier type="DOI">10.1007/978-3-031-01584-7</docidentifier>
        <docidentifier type="IETF" scope="anchor">IEEE-TM 2</docidentifier>
        <docidentifier type="IETF">IEEE 2</docidentifier>
        </bibitem>
    INPUT
    p = Relaton::Render::General.new
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["IEEE 2"]

    input = <<~INPUT
        <bibitem id="ref_pddl" type="book" schema-version="v1.2.4">  <fetched>2023-09-29</fetched>
      <title type="main" format="text/plain" script="Latn">An Introduction to the Planning Domain Definition Language</title>
        <docidentifier type="DOI">10.1007/978-3-031-01584-7</docidentifier>
        <docidentifier scope="anchor">IEEE-TM 2</docidentifier>
        <docidentifier type="IETF">IEEE 2</docidentifier>
        </bibitem>
    INPUT
    p = Relaton::Render::General.new
    data, = p.parse(input)
    expect(data[:authoritative_identifier])
      .to eq ["IEEE 2"]
  end

  it "drop ISSN/ISBN type from docidentifier prefixing" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <docidentifier type="DOI">https://doi.org/10.1017/9781108877831</docidentifier>
        <docidentifier type="ISBN.electronic">9781108877831</docidentifier>
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
      <formattedref>JENKINS and Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em> [preprint]. n.p.: 2022. DOI: https://doi.org/10.1017/9781108877831. ISBN: 9781108877831. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [viewed: October 12, 2022].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end
end

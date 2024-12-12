# encoding: utf-8

require "spec_helper"

RSpec.describe Relaton::Render do
  it "has a version number" do
    expect(Relaton::Render::VERSION).not_to be nil
  end

  it "copes with multiple uris in citation" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338797/</uri>
        <uri>https://eprints.soton.ac.uk/338798/</uri>
        <uri>https://eprints.soton.ac.uk/338799/</uri>
        <date type="accessed"><on>2023-08-31</on></date>
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
      <formattedref>JENKINS und Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em> [preprint]. o.O.: o.J. <link target='https://eprints.soton.ac.uk/338797/'>https://eprints.soton.ac.uk/338797/</link>. [angesehen: 31. August 2023].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "de")
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "picks right uri by type and language: citation is prioritised" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338791/</uri>
        <uri language="de">https://eprints.soton.ac.uk/338792/</uri>
        <uri language="en">https://eprints.soton.ac.uk/338793/</uri>
        <uri type="citation">https://eprints.soton.ac.uk/338794/</uri>
        <uri type="citation" language="de">https://eprints.soton.ac.uk/338795/</uri>
        <uri type="citation" language="en">https://eprints.soton.ac.uk/338796/</uri>
        <date type="accessed"><on>2023-08-31</on></date>
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
      <formattedref>JENKINS und Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em> [preprint]. o.O.: o.J. <link target='https://eprints.soton.ac.uk/338795/'>https://eprints.soton.ac.uk/338795/</link>. [angesehen: 31. August 2023].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "de")
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "picks right uri by type and language: DOI is ignored" do
    input = <<~INPUT
      <bibitem type="book">
        <title>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</title>
        <uri>https://eprints.soton.ac.uk/338791/</uri>
        <uri type="DOI">https://eprints.soton.ac.uk/338794/</uri>
        <uri type="DOI" language="de">https://eprints.soton.ac.uk/338795/</uri>
        <uri type="DOI" language="en">https://eprints.soton.ac.uk/338796/</uri>
        <date type="accessed"><on>2023-08-31</on></date>
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
      <formattedref>JENKINS und Janne RUOSTEKOSKI. <em>Controlled manipulation of light by cooperativeresponse of atoms in an optical lattice</em> [preprint]. o.O.: o.J. <link target='https://eprints.soton.ac.uk/338791/'>https://eprints.soton.ac.uk/338791/</link>. [angesehen: 31. August 2023].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new(language: "de")
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "deals with URIs containing underscore" do
    input = <<~INPUT
      <bibitem type="software">
        <title>metanorma-standoc</title>
        <uri>https://github.com/metanorma/metanorma_standoc</uri>
        <date type="published"><on>2019-09-04</on></date>
        <date type="accessed"><on>2019-09-04</on></date>
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
      <formattedref>Ribose Inc. <em>metanorma-standoc</em>. Version 1.3.1. 2019. <link target="https://github.com/metanorma/metanorma_standoc">https://github.com/metanorma/metanorma_standoc</link>. [viewed: September 4, 2019].</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
  end

  it "do not supply missing accessed date" do
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
      # <formattedref>Ribose Inc. <em>metanorma-standoc</em>. Version 1.3.1. 2019. <link target="https://github.com/metanorma/metanorma-standoc">https://github.com/metanorma/metanorma-standoc</link>. [viewed: #{Date.today.strftime('%B %-d, %Y')}].</formattedref>
    output = <<~OUTPUT
      <formattedref>Ribose Inc. <em>metanorma-standoc</em>. Version 1.3.1. 2019. <link target="https://github.com/metanorma/metanorma-standoc">https://github.com/metanorma/metanorma-standoc</link>.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
    p = Relaton::Render::General.new
    expect { p.render(input) }
      .not_to output(/BIBLIOGRAPHY WARNING: cannot access/)
      .to_stderr

    input = <<~INPUT
      <bibitem type="software">
        <title>metanorma-standoc</title>
        <uri>https://completely.broken.url.com</uri>
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
      <formattedref>Ribose Inc. <em>metanorma-standoc</em>. Version 1.3.1. 2019. <link target="https://completely.broken.url.com">https://completely.broken.url.com</link>.</formattedref>
    OUTPUT
=begin
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
    p = Relaton::Render::General.new
    expect { p.render(input) }
      .to output(%r{BIBLIOGRAPHY WARNING: cannot access https://completely.broken.url.com})
      .to_stderr
=end

    input = <<~INPUT
      <bibitem type="software">
        <title>metanorma-standoc</title>
        <uri>file/file.xml</uri>
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
      # <formattedref>Ribose Inc. <em>metanorma-standoc</em>. Version 1.3.1. 2019. <link target="file/file.xml">file/file.xml</link>. [viewed: #{Date.today.strftime('%B %-d, %Y')}].</formattedref>
    output = <<~OUTPUT
      <formattedref>Ribose Inc. <em>metanorma-standoc</em>. Version 1.3.1. 2019. <link target="file/file.xml">file/file.xml</link>.</formattedref>
    OUTPUT
    p = Relaton::Render::General.new
    expect(p.render(input))
      .to be_equivalent_to output
    p = Relaton::Render::General.new
    expect { p.render(input) }
      .not_to output(%r{BIBLIOGRAPHY WARNING: cannot access file/file.xml})
      .to_stderr
  end
end

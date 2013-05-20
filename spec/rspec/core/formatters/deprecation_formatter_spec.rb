require 'spec_helper'
require 'rspec/core/formatters/deprecation_formatter'
require 'tempfile'

module RSpec::Core::Formatters
  describe DeprecationFormatter do
    describe "#deprecation" do
      let(:deprecation_stream) { StringIO.new }
      let(:summary_stream)     { StringIO.new }
      let(:formatter) { DeprecationFormatter.new deprecation_stream, summary_stream }

      it "includes the method" do
        formatter.deprecation(:method => "i_am_deprecated")
        deprecation_stream.rewind
        expect(deprecation_stream.read).to match(/i_am_deprecated is deprecated/)
      end

      it "includes the replacement" do
        formatter.deprecation(:alternate_method => "use_me")
        deprecation_stream.rewind
        expect(deprecation_stream.read).to match(/Use use_me instead/)
      end

      it "includes the call site if provided" do
        formatter.deprecation(:called_from => "somewhere")
        deprecation_stream.rewind
        expect(deprecation_stream.read).to match(/Called from somewhere/)
      end

      it "prints a message if provided, ignoring other data" do
        formatter.deprecation(:message => "this message", :method => "x", :alternate_method => "y", :called_from => "z")
        deprecation_stream.rewind
        expect(deprecation_stream.read).to eq "this message"
      end
    end

    describe "#deprecation_summary" do
      it "is printed when deprecations go to a file" do
        file = Tempfile.new('foo')
        summary_stream = StringIO.new
        formatter = DeprecationFormatter.new file.path, summary_stream
        formatter.deprecation(:method => 'whatevs')
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to match(/1 deprecation logged to .*foo/)
      end

      it "pluralizes for more than one deprecation" do
        file = Tempfile.new('foo')
        summary_stream = StringIO.new
        formatter = DeprecationFormatter.new file.path, summary_stream
        formatter.deprecation(:method => 'whatevs')
        formatter.deprecation(:method => 'whatevs_else')
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to match(/2 deprecations/)
      end

      it "is not printed when there are no deprecations" do
        file = Tempfile.new('foo')
        summary_stream = StringIO.new
        formatter = DeprecationFormatter.new file.path, summary_stream
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to eq ""
      end

      it "is not printed when deprecations go to an IO instance" do
        summary_stream = StringIO.new
        formatter = DeprecationFormatter.new StringIO.new, summary_stream
        formatter.deprecation(:method => 'whatevs')
        formatter.deprecation_summary
        summary_stream.rewind
        expect(summary_stream.read).to eq ""
      end
    end
  end
end
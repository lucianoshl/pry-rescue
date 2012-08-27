require File.expand_path('../../lib/pry-rescue.rb', __FILE__)
require 'uri'

describe "PryRescue.load" do
  if defined?(PryStackExplorer)
    it "should open at the correct point" do
      PryRescue.should_receive(:pry).once{ |opts|
        opts[:call_stack].first.eval("__FILE__").should end_with('spec/fixtures/simple.rb')
      }
      lambda{
        PryRescue.load("spec/fixtures/simple.rb")
      }.should raise_error(/fixtures.simple/)
    end

    it "should open above the standard library" do
      PryRescue.should_receive(:pry).once do |opts|
        opts[:call_stack][opts[:initial_frame]].eval("__FILE__").should end_with('spec/fixtures/uri.rb')
      end
      lambda{
        PryRescue.load("spec/fixtures/uri.rb")
      }.should raise_error(URI::InvalidURIError)
    end

    it "should keep the standard library on the binding stack" do
      PryRescue.should_receive(:pry).once do |opts|
        opts[:call_stack].first.eval("__FILE__").should start_with(RbConfig::CONFIG['libdir'])
      end
      lambda{
        PryRescue.load("spec/fixtures/uri.rb")
      }.should raise_error(URI::InvalidURIError)
    end

    it "should open above gems" do
      PryRescue.should_receive(:pry).once do |opts|
        opts[:call_stack][opts[:initial_frame]].eval("__FILE__").should end_with('spec/fixtures/coderay.rb')
      end
      lambda{
        PryRescue.load("spec/fixtures/coderay.rb")
      }.should raise_error(ArgumentError)
    end


    it "should open above gems" do
      PryRescue.should_receive(:pry).once do |opts|
        opts[:call_stack].first.eval("__FILE__").should start_with(Gem::Specification.detect{|x| x.name == 'coderay' }.full_gem_path)
      end
      lambda{
        PryRescue.load("spec/fixtures/coderay.rb")
      }.should raise_error(ArgumentError)
    end
  else
    it "should open at the correct point" do
      Pry.should_receive(:start).once{ |binding, h|
        binding.eval("__FILE__").should end_with('spec/fixtures/simple.rb')
      }
      lambda{
        PryRescue.load("spec/fixtures/simple.rb")
      }.should raise_error(/fixtures.simple/)
    end
  end
end
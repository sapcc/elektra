require 'spec_helper'

describe Swift::Object do

  before :each do
    @driver = double('driver').as_null_object
  end

  describe '#basename' do
    it 'shows the basename of the given path' do
      {
        'abc'       => 'abc',
        'abc/'      => 'abc/',
        'abc.def'   => 'abc.def',
        'abc.def/'  => 'abc.def/',
        'abc/def'   => 'def',
        'abc/def/'  => 'def/',
        'ab/cd/ef'  => 'ef',
        'ab/cd/ef/' => 'ef/',
      }.each do |path,basename|
        expect(Swift::Object.new(@driver, id: path).basename).to eq(basename)
      end
    end
  end

  describe '#dirname' do
    it 'shows the dirname of the given path' do
      {
        'abc'       => '',
        'abc/'      => '',
        'abc.def'   => '',
        'abc.def/'  => '',
        'abc/def'   => 'abc',
        'abc/def/'  => 'abc',
        'ab/cd/ef'  => 'ab/cd',
        'ab/cd/ef/' => 'ab/cd',
      }.each do |path,dirname|
        expect(Swift::Object.new(@driver, id: path).dirname).to eq(dirname)
      end
    end
  end

end

# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/manage_connector'

RSpec.describe 'the manage_connector type' do
  it 'loads' do
    expect(Puppet::Type.type(:manage_connector)).not_to be_nil
  end
end

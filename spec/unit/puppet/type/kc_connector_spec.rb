# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/kc_connector'

RSpec.describe 'the kc_connector type' do
  it 'loads' do
    expect(Puppet::Type.type(:kc_connector)).not_to be_nil
  end
end

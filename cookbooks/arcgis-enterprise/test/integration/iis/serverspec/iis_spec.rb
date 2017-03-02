require 'spec_helper'

describe service('W3SVC') do
  it { should be_enabled }
  it { should be_running }
end

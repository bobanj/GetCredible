require 'spec_helper'

describe Authentication do
  describe "Validations" do
    it { should validate_presence_of(:provider) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:token) }
    it { should validate_presence_of(:secret) }
  end
end

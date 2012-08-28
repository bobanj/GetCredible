FactoryGirl.define do
  factory :link do |f|
    f.user      { FactoryGirl.create(:user, full_name: 'Uzumaki Naruto') }
    f.url       { 'http://www.example.com' }
    f.title     { 'Example title' }
    f.tag_names { 'example' }
  end
end

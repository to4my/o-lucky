require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { FactoryBot.build_stubbed(:user, name: 'Mike') }

  it 'shows username' do
    assign(:user, user)

    render

    expect(rendered).to match 'Mike'
  end

  it 'shows change password button if current_user' do
    assign(:user, user)
    allow(view).to receive(:current_user).and_return(user)

    render

    expect(rendered).to match 'Сменить имя и пароль'
  end

  it 'does not show change password button if not current_user' do
    another_user = FactoryBot.build_stubbed(:user, name: 'Mike')

    assign(:user, another_user)
    allow(view).to receive(:current_user).and_return(user)

    render

    expect(rendered).not_to match 'Сменить имя и пароль'
  end

  it 'shows game partial' do
    assign(:user, user)
    assign(:games, [FactoryBot.build_stubbed(:game)])

    stub_template 'users/_game.html.erb' => 'User game goes here'

    render

    expect(rendered).to match 'User game goes here'
  end
end

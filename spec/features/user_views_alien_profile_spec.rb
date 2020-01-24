require 'rails_helper'

RSpec.feature 'User views alien profile', type: :feature do
  let(:user) { FactoryGirl.create(:user, name: 'Админ') }
  let(:another_user) { FactoryGirl.create(:user, name: 'Юзверь') }

  let!(:games) do
    [
      FactoryGirl.create(
        :game,
        user: another_user,
        prize: 16_000,
        current_level: 8,
        created_at: Time.parse('2020-01-24 14:00'),
        finished_at: Time.parse('2020-01-24 14:15'),
        is_failed: false
      ),
      FactoryGirl.create(
        :game,
        user: another_user,
        prize: 1_000,
        current_level: 6,
        created_at: Time.parse('2020-01-24 13:00'),
        finished_at: Time.parse('2020-01-24 13:30'),
        is_failed: true
      )
    ]
  end

  before(:each) { login_as user }

  scenario 'successfully' do
    visit '/'

    click_link 'Юзверь'

    expect(page).to have_current_path "/users/#{another_user.id}"

    expect(page).to have_content 'Юзверь'
    expect(page).not_to have_content 'Сменить имя и пароль'

    expect(page).to have_selector "#game-#{games.first.id}"

    within "#game-#{games.first.id}" do
      expect(page).to have_content 'деньги'
      expect(page).to have_content '24 янв., 14:00'
      expect(page).to have_content '8'
      expect(page).to have_content '16 000 ₽'
    end

    expect(page).to have_selector "#game-#{games[1].id}"

    within "#game-#{games[1].id}" do
      expect(page).to have_content 'проигрыш'
      expect(page).to have_content '24 янв., 13:00'
      expect(page).to have_content '6'
      expect(page).to have_content '1 000 ₽'
    end
    save_and_open_page
  end
end
# (c) goodprogrammer.ru

# Стандартный rspec-овский помощник для rails-проекта
require 'rails_helper'

# Наш собственный класс с вспомогательными методами
require 'support/my_spec_helper'

# Тестовый сценарий для модели Игры
#
# В идеале — все методы должны быть покрыты тестами, в этом классе содержится
# ключевая логика игры и значит работы сайта.
RSpec.describe Game, type: :model do
  # Пользователь для создания игр
  let(:user) { FactoryBot.create(:user) }

  # Игра с прописанными игровыми вопросами
  let(:game_w_questions) do
    FactoryBot.create(:game_with_questions, user: user)
  end

  # Группа тестов на работу фабрики создания новых игр
  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      # Генерим 60 вопросов с 4х запасом по полю level, чтобы проверить работу
      # RANDOM при создании игры.
      generate_questions(60)

      game = nil

      # Создaли игру, обернули в блок, на который накладываем проверки
      expect {
        game = Game.create_game_for_user!(user)
        # Проверка: Game.count изменился на 1 (создали в базе 1 игру)
      }.to change(Game, :count).by(1).and(
          # GameQuestion.count +15
          change(GameQuestion, :count).by(15).and(
              # Game.count не должен измениться
              change(Question, :count).by(0)
          )
      )

      # Проверяем статус и поля
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)

      # Проверяем корректность массива игровых вопросов
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  # Тесты на основную игровую логику
  context 'game mechanics' do
    # Правильный ответ должен продолжать игру
    it 'answer correct continues game' do
      # Текущий уровень игры и статус
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      # Перешли на след. уровень
      expect(game_w_questions.current_level).to eq(level + 1)

      expect(game_w_questions.current_game_question).not_to eq(q)

      # Игра продолжается
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end
  end

  context 'answer current question' do

    it 'timeout -> returns false' do
      game_w_questions.created_at = 1.hour.ago

      expect(game_w_questions.answer_current_question!('d')).to be false
      expect(game_w_questions.finished?).to be true
      expect(game_w_questions.status).to eq(:timeout)
    end

    it 'wrong answer -> return false' do
      expect(game_w_questions.answer_current_question!('a')).to be false
      expect(game_w_questions.finished?).to be true
      expect(game_w_questions.status).to eq(:fail)
    end

    it 'answer  right -> game continues' do
      expect(game_w_questions.answer_current_question!('d')).to be true
      expect(game_w_questions.current_level).to eq(1)
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).not_to be true
    end

    it 'last answer right to game win' do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max

      expect(game_w_questions.answer_current_question!('d')).to be true
      expect(game_w_questions.finished?).to be true
      expect(game_w_questions.status).to eq(:won)
      expect(game_w_questions.prize).to eq(Game::PRIZES.last)
    end
  end
end

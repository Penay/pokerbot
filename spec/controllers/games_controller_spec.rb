require 'spec_helper'

describe GamesController do
  let(:game) {FactoryGirl.create(:game)}
  def login_user
    sign_in(@current_user = FactoryGirl.create(:user, email: 'example+user@gmail.com', password: 'password', password_confirmation: 'password'))
  end

  before do
    login_user
  end

  # share_examples_for "any action" do
  #   it { expect { get :action, game.id }.to raise_error(ActiveRecord::RecordNotFound) }
  # end

  render_views

  describe "GET 'index'" do
    it "shows list of games" do
      game1 = FactoryGirl.create(:game)
      game2 = FactoryGirl.create(:game)
      get 'index'
      assigns(:games).should include(game1)
      assigns(:games).should include(game2)
    end
    it "renders template" do
      get 'index'
      response.should render_template('index')
    end
  end
  #
  describe "GET 'show'" do
    before(:each) do
      get 'show', id: game.id
    end
    context "when game exists" do
      it "shows appropriate game" do
        assigns(:game).should == game
      end
      it "renders template" do
        response.should render_template('show')
      end
    end
    context "when game doesn't exist" do
      it "raises error" do
        expect {delete 'destroy', id: game.id+1}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  #
  describe "DELETE 'delete'" do
    context "when game exists" do
      it "redirects on success" do
        delete 'destroy', id: game.id
        response.should redirect_to root_path
      end
      it "shows flash notice" do
        delete 'destroy', id: game.id
        flash[:notice].should == "Game is successfully deleted!"
      end
    end
    context "when game doesn't exist" do
      it "raises error" do
        expect {delete 'destroy', id: game.id+1}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  #
  describe "PUT 'update'" do
    context "when params are valid" do
      #it "returns http success" do
      #  put 'update', id: game.id, game: {}
      #  response.should be_success
      #end
    end
    #context "when params are invalid" do
    #  it "renders 'edit'" do
    #    put 'update', id: game.id, game: {}
    #    response.should render_template('edit')
    #  end
    #end
  end
  #
  #describe "GET 'edit'" do
  #  it "renders template" do
  #    get 'edit', id: game.id
  #    response.should render_template('edit')
  #  end
  #end
  #
  describe "GET 'new'" do
    it "renders template" do
      get :new
      response.should render_template('new')
    end
  end
  #
  describe "POST 'create'" do
    context "when params are valid" do
      it "returns http success" do
        post 'create', game: {}
        response.should redirect_to Game.last
      end
    end
    context "when params are invalid" do
      #it "redirects to 'show'" do
      #  post 'create', game: {}
      #  response.should redirect_to games_path
      #end
      it "shows flash success" do
        post 'create', game: {}
        flash[:success] == "You successfully created game!"
      end
    end
  end

  describe "PUT 'start'" do
    before do
      put :start, id: game.id
    end
    it "assigns deck to game" do
      game.deck.should be_instance_of(Deck)
    end
    it { flash[:notice] == 'You started game.' }
    it { response.should redirect_to game}
    it "status should be started" do
      game.reload.status.should == "started"
    end
  end

  describe "PUT 'check'" do
    before do
      put :check, id: game.id
    end
  end

  describe "PUT 'raise'" do
    before do
      put :raise, id: game.id
    end
  end

  describe "PUT 'fold'" do
    before do
      put :fold, id: game.id
    end
  end


end

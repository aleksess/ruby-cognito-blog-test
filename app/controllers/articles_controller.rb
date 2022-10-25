class ArticlesController < ApplicationController

    skip_before_action :validate_session, only: [:index, :show]

    def index
        @articles = Article.all.order(created_at: :desc)
    end

    def show
        @article = Article.find(params[:id])
    end

    def new
        @article = ArticleDto.new
    end

    def create
        @dto = ArticleDto.new(title: create_article_params[:title], body: create_article_params[:body])

        if !@dto.valid?
            render '/articles/new', status: :unprocessable_entity
            return
        end

        @article = Article.new(title: @dto.title, body: @dto.body, author: session[:username])

        if @article.save
            redirect_to '/'
        else 
            render '/articles/new', status: :unprocessable_entity
        end
    end

    private
        def create_article_params
            params.require(:article_dto).permit(:title, :body)
        end
end

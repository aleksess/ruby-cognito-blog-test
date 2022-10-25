class ArticleDto
    include ActiveModel::API

    attr_accessor :title, :body
    validates :title, :body, presence: true
end
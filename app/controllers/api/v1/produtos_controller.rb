module Api
  module V1
    class ProdutosController < BaseController
      before_action :set_produto, only: [:show, :update, :destroy]

      # GET /api/v1/produtos
      def index
        @produtos = Produto.all
        render json: ProdutoSerializer.new(@produtos).serializable_hash.to_json, status: :ok
      end

      # GET /api/v1/produtos/:id
      def show
        render json: ProdutoSerializer.new(@produto).serializable_hash.to_json, status: :ok
      end

      # POST /api/v1/produtos
      def create
        @produto = Produto.new(produto_params)

        if @produto.save
          render json: ProdutoSerializer.new(@produto).serializable_hash.to_json, status: :created
        else
          render json: { errors: @produto.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/produtos/:id
      def update
        if @produto.update(produto_params)
          render json: ProdutoSerializer.new(@produto).serializable_hash.to_json, status: :ok
        else
          render json: { errors: @produto.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/produtos/:id
      def destroy
        @produto.destroy
        head :no_content
      end

      private

      def set_produto
        @produto = Produto.find(params[:id])
      end

      def produto_params
        params.require(:produto).permit(:name, :description, :price, :stock_quantity)
      end
    end
  end
end

module Api
  module V1
    class PedidosController < BaseController
      before_action :set_pedido, only: [:show, :update, :destroy]

      # GET /api/v1/pedidos
      def index
        @pedidos = Pedido.includes(:itens).all
        render json: PedidoSerializer.new(@pedidos, include: [:itens]).serializable_hash.to_json, status: :ok
      end

      # GET /api/v1/pedidos/:id
      def show
        render json: PedidoSerializer.new(@pedido, include: [:itens]).serializable_hash.to_json, status: :ok
      end

      # POST /api/v1/pedidos
      def create
        @pedido = Pedido.new(pedido_params)

        if @pedido.save
          render json: PedidoSerializer.new(@pedido, include: [:itens]).serializable_hash.to_json, status: :created
        else
          render json: { errors: @pedido.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/pedidos/:id
      def update
        if @pedido.update(pedido_params)
          render json: PedidoSerializer.new(@pedido, include: [:itens]).serializable_hash.to_json, status: :ok
        else
          render json: { errors: @pedido.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/pedidos/:id
      def destroy
        @pedido.destroy
        head :no_content
      end

      private

      def set_pedido
        @pedido = Pedido.includes(:itens).find(params[:id])
      end

      def pedido_params
        params.require(:pedido).permit(
          :customer_name, 
          :status,
          itens_attributes: [:id, :produto_id, :quantity, :unit_price, :_destroy]
        )
      end
    end
  end
end

class Spree::Admin::GiftCardsController < Spree::Admin::BaseController
  before_filter :load_gift_card_history, only: [:show]
  before_filter :load_user, only: [:lookup, :redeem]
  before_filter :load_gift_card_for_redemption, only: [:redeem]
  before_filter :load_gift_card_by_id, only: [:edit, :update]
  before_filter :load_order, only: [:edit, :update]

  def index
  end

  def show
  end

  def edit
  end

  def update
    if @gift_card.update_attributes(gift_card_params)
      flash[:success] = Spree.t("admin.gift_cards.gift_card_updated")
      redirect_to edit_admin_order_path(@order)
    else
      flash[:error] = @gift_card.errors.full_messages.join(", ")
      redirect_to :back
    end
  end

  def lookup
  end

  def redeem
    if @gift_card.redeem(@user)
      flash[:success] = Spree.t("admin.gift_cards.redeemed_gift_card")
      redirect_to admin_user_store_credits_path(@user)
    else
      flash[:error] = Spree.t("admin.gift_cards.errors.unable_to_redeem_gift_card")
      render :lookup
    end
  end

  private

  def load_gift_card_history
    redemption_code = Spree::RedemptionCodeGenerator.format_redemption_code_for_lookup(params[:id])
    @gift_cards = Spree::VirtualGiftCard.where(redemption_code: redemption_code)

    if @gift_cards.empty?
      flash[:error] = Spree.t('admin.gift_cards.errors.not_found')
      redirect_to(admin_gift_cards_path)
    end
  end

  def load_gift_card_for_redemption
    redemption_code = Spree::RedemptionCodeGenerator.format_redemption_code_for_lookup(params[:gift_card][:redemption_code])
    @gift_card = Spree::VirtualGiftCard.active_by_redemption_code(redemption_code)

    if @gift_card.blank?
      flash[:error] = Spree.t("admin.gift_cards.errors.not_found")
      render :lookup
    end
  end

  def load_gift_card_by_id
    @gift_card = Spree::VirtualGiftCard.find_by(id: params[:id])
  end

  def load_order
    @order = Spree::Order.find_by(number: params[:order_id])
  end

  def load_user
    @user = Spree::User.find(params[:user_id])
  end

  def gift_card_params
    params.require(:virtual_gift_card).permit(:recipient_name, :recipient_email, :purchaser_name, :gift_message, :send_email_at)
  end

  def model_class
    Spree::VirtualGiftCard
  end
end

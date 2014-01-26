require 'spec_helper'

describe Spree::Order do
  let(:user) { Spree::User.create!(:email => 'test@testmail.com', :password => '123456') }
  let(:order) { Spree::Order.create! { |order| order.user = user }}
  
  before(:each) do
    order.update_column(:total, 1000)
    order.update_column(:payment_total, 200)
    @shipping_category = Spree::ShippingCategory.create!(:name => 'test')
    @stock_location = Spree::StockLocation.create! :name => 'test' 
    @product = Spree::Product.create!(:name => "product", :price => 100) { |p| p.shipping_category = @shipping_category }
    @stock_item = @product.master.stock_items.first
    @stock_item.adjust_count_on_hand(10)
    @stock_item.save!

    order.line_items.create! :variant_id => @product.master.id, :quantity => 1
  end

  def create_order_with_state(state)
    Spree::Order.create! do |order|
      order.user = user
      order.state = state
      total = 100
    end
  end

  describe 'paga_payment' do
    context 'when paga_payment present' do
      before(:each) do
        @paga_payment_method = Spree::PaymentMethod::Paga.create(:name => "paga epay", :environment => Rails.env)
      end

      context 'when payment state is checkout' do
        before do
          @paga_payment = order.payments.create!(:amount => 100, :payment_method_id => @paga_payment_method.id) { |p| p.state = 'checkout' }
        end

        it "should return paga_payment" do
          order.paga_payment.should eq(@paga_payment)
        end

      end

      context 'when payment state is pending' do
        before do
          @paga_payment = order.payments.create!(:amount => 100, :payment_method_id => @paga_payment_method.id) { |p| p.state = 'checkout' }
        end

        it "should return paga_payment" do
          order.paga_payment.should eq(@paga_payment)
        end
      end
    end

    context 'when paga_payment not present' do
      it "should return nil" do
        order.paga_payment.should be_nil
      end
    end
  end

  describe 'payment_or_complete_or_pending' do
    context 'when order complete' do
      before do
        @order = create_order_with_state("complete")
      end

      it "should return true" do
        @order.payment_or_complete_or_pending?.should be_true
      end
    end

    context 'when order pending' do
      before do
        @order = create_order_with_state("pending")
      end

      it "should return true" do
        @order.payment_or_complete_or_pending?.should be_true
      end
    end

    context 'when order payment' do
      before do
        @order = create_order_with_state("payment")
      end

      it "should return true" do
        @order.payment_or_complete_or_pending?.should be_true
      end
    end

    context 'when order neither complete nor pending nor payment' do
      before do
        @order = create_order_with_state("cart")
      end

      it "should return true" do
        @order.payment_or_complete_or_pending?.should be_false
      end
    end
  end

  describe 'scope not_pending' do
    def create_order_with_state(state)
      Spree::Order.create! do |order|
        order.user = user
        order.state = state
        total = 100
      end
    end

    before do
      @order = create_order_with_state("pending")
      @order1 = create_order_with_state("complete")
    end

    it "should return non pending orders" do
      Spree::Order.not_pending.should =~ [order, @order1]
    end
  end

  describe 'remaining total' do
    before do
      @order = create_order_with_state("complete")
    end

    it "should return order total" do
      @order.remaining_total.should eq(@order.total)
    end
  end

  describe 'transition from payment to pending' do
    before do
      @order = create_order_with_state("payment")
    end
    it "should be able to change state from payment to pending" do
      @order.pending!
      @order.state.should eq("pending")
    end
  end


  describe 'finalize_order' do
    before do
      @paga_payment_method = Spree::PaymentMethod::Paga.create(:name => "paga epay", :environment => Rails.env)
      @order = create_order_with_state("pending")
      @payment = @order.payments.create!(:amount => 100, :payment_method_id => @paga_payment_method.id) { |p| p.state = 'checkout' }
    end

    it "should receive complete!" do
      @order.finalize_order
      @order.state.should eq("complete")
    end

    it "set completed_at for order" do
      @order.finalize_order
      @order.completed_at.should be_within(2.seconds).of(Time.current)
    end

    it "should set payment to complete" do
      @order.finalize_order
      @payment.reload.state.should eq("completed")
    end

    it "should receive finalize!" do
      @order.should_receive(:finalize!)
      @order.finalize_order
    end

  end

end
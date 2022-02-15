/**
 * @description       : To create test data for contact, oppty etc.
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-15-2022   Arunava(Cognizant)   Initial Version
 **/
 
@IsTest
public class TestDataBuilder{
	private static final Map<String, Schema.RecordTypeInfo> OPP_RT2INFO = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
	private static final Map<String, Schema.RecordTypeInfo> PROD_RT2INFO = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();

	public class Pricebook2Builder{
		Pricebook2 pricebook = new Pricebook2();
		public Pricebook2Builder withName(String name){
			pricebook.Name = name;
			return this;
		}
		public Pricebook2 build(){
			return pricebook;
		}
	}
	public static Pricebook2Builder aPricebook2(){
		return new Pricebook2Builder();
	}

	public class PricebookEntryBuilder{
		PricebookEntry pricebook = new PricebookEntry(
			Pricebook2Id = Test.getStandardPricebookId(),
			UnitPrice = 1.0, IsActive = true
		);
		public PricebookEntryBuilder withUnitPrice(Integer Unit){
			pricebook.UnitPrice = Unit;
			return this;
		}
		public PricebookEntryBuilder withPricebook2(Pricebook2 priceb){
			pricebook.Pricebook2Id = priceb.Id;
			return this;
		}
		public PricebookEntryBuilder withPricebook2(Id value){
			pricebook.Pricebook2Id = value;
			return this;
		}
		public PricebookEntryBuilder withProduct2(Product2 product){
			pricebook.Product2Id = product.Id;
			return this;
		}
		public PricebookEntryBuilder withActive(Boolean bool){
			pricebook.IsActive = bool;
			return this;
		}
		public PricebookEntry build(){
			return pricebook;
		}
	}
	public static PricebookEntryBuilder aPricebookEntry(){
		return new PricebookEntryBuilder();
	}

	public class Product2Builder{
		Product2 product = new Product2(Name = 'Test', IsActive = true);
		public Product2Builder withName(String Name){
			product.Name = Name;
			return this;
		}
		public Product2Builder withActive(Boolean Bool){
			product.IsActive = Bool;
			return this;
		}
		public Product2 build(){
			return Product;
		}
	}
	public static Product2Builder aProduct2(){
		return new Product2Builder();
	}

	public class AccountBuilder{
		Account Acc = new Account();
		public AccountBuilder withName(String name){
			Acc.Name = name;
			return this;
		}
		public AccountBuilder withPhone(String value){
			Acc.Phone = value;
			return this;
		}
		public Account build(){
			return acc;
		}
	}
	public static AccountBuilder anAccount(){
		return new AccountBuilder();
	}

	public class OrderBuilder{
		Order order = new Order(Name = 'KPN TEST ORDER', EffectiveDate = Date.today(), Status = 'Draft');
		public OrderBuilder withAccount(Account acc){
			order.AccountId = acc.Id;
			return this;
		}
		public OrderBuilder withEffectiveDate(date EffDate){
			order.EffectiveDate = EffDate;
			return this;
		}
		public OrderBuilder withName(String Name){
			order.Name = name;
			return this;
		}
		public OrderBuilder withPricebook2(id price2){
			order.Pricebook2Id = price2;
			return this;
		}
		public OrderBuilder withPricebook2(Pricebook2 price2){
			order.Pricebook2Id = price2.Id;
			return this;
		}
		public OrderBuilder withStatus(String stat){
			order.Status = stat;
			return this;
		}
		public Order build(){
			return Order;
		}
	}
	public static orderBuilder aOrder(){
		return new OrderBuilder();
	}

	public class OrderItemBuilder{
		OrderItem OrdersItem = new OrderItem(Quantity = 1, UnitPrice = 1);
		public OrderItemBuilder withOrder(Order order){
			OrdersItem.OrderId = order.Id;
			return this;
		}
		public OrderItemBuilder withQuantity(integer quant){
			OrdersItem.Quantity = quant;
			return this;
		}
		public OrderItemBuilder withPriceBook(PricebookEntry price){
			OrdersItem.PricebookEntryId = price.Id;
			return this;
		}
		public OrderItemBuilder withUnitPrice(decimal Unit){
			OrdersItem.UnitPrice = Unit;
			return this;
		}
		public OrderItem build(){
			return OrdersItem;
		}
	}
	public static OrderItemBuilder aOrderItem(){
		return new OrderItemBuilder();
	}

    public static List<PricebookEntry> getPricebookEntries(String pbName){
		return [SELECT Product2.Name, UnitPrice FROM PricebookEntry WHERE Pricebook2.Name =: pbName LIMIT 5];
	}
	public static Order getOrder(String orderName){
		return [SELECT id, Status FROM Order WHERE Name =: orderName LIMIT 1];
	}

}
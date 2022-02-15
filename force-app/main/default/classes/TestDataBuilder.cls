/**
 * @description       : Class for capturing status and messages
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-10-2022   Arunava(Cognizant)   Initial Version
 **/
 
@IsTest
public class testDataBuilder{
	private static final Map<String, Schema.RecordTypeInfo> OPP_RT2INFO = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
	private static final Map<String, Schema.RecordTypeInfo> PROD_RT2INFO = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
	/**
	 * @description Contact Builder
	*/
	public class ContactBuilder{
		private Contact obj = new Contact(LastName = 'STRING');
		public ContactBuilder withLastName(String value){
			obj.LastName = value;
			return this;
		}

		public ContactBuilder withFirstName(String value){
			obj.FirstName = value;
			return this;
		}

		public ContactBuilder withMailingCity(String value){
			obj.MailingCity = value;
			return this;
		}

		public ContactBuilder withEmail(String value){
			obj.Email = value;
			return this;
		}

		public ContactBuilder withTitle(String value){
			obj.Title = value;
			return this;
		}

		public ContactBuilder withOwnerId(User value){
			obj.OwnerId = value.Id;
			return this;
		}

		public Contact build(){
			return obj;
		}
	}
	public static ContactBuilder aContact(){
		return new ContactBuilder();
	}
	/**
	 * @description Opportunity Builder
	*/
	public class OpportunityBuilder{
		Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Test Stage', CloseDate = Date.today());
		public OpportunityBuilder withName(String name){
			opp.Name = name;
			return this;
		}
		public OpportunityBuilder withAccount(Account acc){
			opp.AccountId = acc.Id;
			return this;
		}
		public OpportunityBuilder withStage(String Stage){
			opp.StageName = Stage;
			return this;
		}
		public OpportunityBuilder withPricebook2Id(String value){
			opp.Pricebook2Id = value;
			return this;
		}
		public OpportunityBuilder withType(String value){
			opp.Type = value;
			return this;
		}
		public OpportunityBuilder withCloseDate(date Close){
			opp.CloseDate = Close;
			return this;
		}

		public OpportunityBuilder withDescription(String value){
			opp.Description = value;
			return this;
		}
		public Opportunity build(){
			return opp;
		}
	}
	public static OpportunityBuilder aOpportunity(){
		return new OpportunityBuilder();
	}
	/**
	 * @description OpportunityLineItem Builder
	*/
	public class OpportunityLineItemsBuilder{
		OpportunityLineItem OLI = new OpportunityLineItem(Quantity = 1, UnitPrice = 1);
		public OpportunityLineItemsBuilder withOpp(Opportunity opp){
			OLI.OpportunityId = opp.Id;
			return this;
		}
		public OpportunityLineItemsBuilder withQuantity(integer quantity){
			OLI.Quantity = quantity;
			return this;
		}
		public OpportunityLineItemsBuilder withPricebookEntry(PricebookEntry price){
			OLI.PricebookEntryId = price.Id;
			return this;
		}
		public OpportunityLineItemsBuilder withTotalPrice(decimal TotalPrice){
			OLI.TotalPrice = TotalPrice;
			return this;
		}
		public OpportunityLineItemsBuilder withUnitPrice(decimal UnitPrice){
			OLI.UnitPrice = UnitPrice;
			return this;
		}
		public OpportunityLineItemsBuilder withProduct2(Product2 product){
			OLI.Product2Id = product.Id;
			return this;
		}
		public OpportunityLineItemsBuilder withProduct2Id(Id idProduct){
			OLI.Product2Id = idProduct;
			return this;
		}
		public OpportunityLineItemsBuilder withDescription(String value){
			OLI.Description = value;
			return this;
		}
		public OpportunityLineItem build(){
			return OLI;
		}
	}
	public static OpportunityLineItemsBuilder aOLI(){
		return new OpportunityLineItemsBuilder();
	}
	/**
	 * @description Account Builder
	*/
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
	/**
	 * @description User Builder
	*/
	public class UserBuilder{
		User Us = new User();
		public UserBuilder withUserName(String name){
			Us.Username = name;
			return this;
		}
		public UserBuilder withLastName(String LastName){
			Us.LastName = LastName;
			return this;
		}
		public UserBuilder withEmail(String Email){
			Us.Email = Email;
			return this;
		}
		public UserBuilder withAlias(String Alias){
			Us.Alias = Alias;
			return this;
		}
		public UserBuilder withCommunityNickName(String NickName){
			Us.CommunityNickname = NickName;
			return this;
		}
		public UserBuilder withTimeZone(String TimeZone){
			Us.TimeZoneSidKey = TimeZone;
			return this;
		}
		public UserBuilder withLocaleSid(String Locale){
			Us.LocaleSidKey = Locale;
			return this;
		}
		public UserBuilder withEmailEncoding(String Email){
			us.EmailEncodingKey = Email;
			return this;
		}
		public UserBuilder withProfile(Profile Prof){
			Us.ProfileId = Prof.Id;
			return this;
		}
		public UserBuilder withLanguageLocale(String Language){
			Us.LanguageLocaleKey = Language;
			return this;
		}
		public User build(){
			return Us;
		}	}

	public static UserBuilder aUser(){
		return new UserBuilder();
	}
	/**
	 * @description Pricebook Builder
	*/
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
	/**
	 * @description Pricebook Entry Builder
	*/
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
	/**
	 * @description Product Builder
	*/
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
	/**
	 * @description Order Builder
	*/
	public class OrderBuilder{
		Order order = new Order(Name = 'Test', EffectiveDate = Date.today(), Status = 'Draft');
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
	/**
	 * @description Order Builder
	*/
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
}
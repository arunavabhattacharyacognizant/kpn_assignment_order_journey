/**
 * @description       : Class for capturing status and messages response
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-10-2022   Arunava(Cognizant)   Initial Version
 **/
 
@isTest
public without sharing class OrderProductsControllerTest {
	private static final String PRICEBOOK_ENTRY_NAME = 'Test Order Pricebook';
	private static final String ORDER_NAME = 'ORDER N. 001';
	@TestSetup
	static void makeData(){
		Account acc = testDataBuilder.anAccount()
			.withName('Test Account')
			.build();
		insert acc;
		/** Build 100 Products */
		List<Product2> testProducts = new List<Product2>();
		for(Integer i = 0; i < 100; i++){
			Product2 testProduct = testDataBuilder.aProduct2()
				.withActive(true)
				.withName('Test Product ' + i)
				.build();
			testProducts.add(testProduct);
		}
		insert testProducts;
		List<PricebookEntry> standardPriceBookList = new List<PricebookEntry>();
		for (Product2 product : testProducts){
			PricebookEntry priceBookEntry = testDataBuilder.aPricebookEntry()
				.withProduct2(product)
				.withActive(product.IsActive)
				.build();
				standardPriceBookList.add(priceBookEntry);
		}
		insert standardPriceBookList;
		/** Add products to custom pricebook */
		Pricebook2 testOrderPriceBook =testDataBuilder.aPricebook2()
			.withName(PRICEBOOK_ENTRY_NAME)
			.build();
		insert testOrderPriceBook;
		List<PricebookEntry> priceBookList = new List<PricebookEntry>();
		for (Product2 product : testProducts){
			PricebookEntry priceBookEntry = testDataBuilder.aPricebookEntry()
				.withPricebook2(testOrderPriceBook)
				.withProduct2(product)
				.withActive(product.IsActive)
				.withUnitPrice(Integer.valueOf((Math.random()*10) + 1))
				.build();
			priceBookList.add(priceBookEntry);
		}
		insert priceBookList;
		Order testOrder = testDataBuilder.aOrder()
			.withAccount(acc)
			.withName(ORDER_NAME)
			.withPricebook2(testOrderPriceBook)
			.build();
		insert testOrder;
		List<PricebookEntry> pbEntries = TestUtils.getPbEntriesByPbName(PRICEBOOK_ENTRY_NAME);
		List<OrderItem> orderItems = new List<OrderItem>();
		for(PricebookEntry pbEntrie : pbEntries){
			OrderItem orderItem = testDataBuilder.aOrderItem()
				.withOrder(testOrder)
				.withQuantity(1)
				.withPriceBook(pbEntrie)
				.withUnitPrice(pbEntrie.UnitPrice)
				.build();
			orderItems.add(orderItem);
		}
		insert orderItems;
	}
	@IsTest
	static void returnOrderProducts(){
		Order testOrder = TestUtils.returnOrder(ORDER_NAME);
		List<OrderItem> orderItems = new List<OrderItem>();
		Test.startTest();
		orderItems = OrderProductsController.getOrderItems(testOrder.Id);
		Test.stopTest();
		System.assertEquals(5, orderItems.size(), 'Five products are expected');
	}
	@IsTest
	static void activateOrderIfCallToExtSystemReturns200(){
		Order testOrder = TestUtils.returnOrder(ORDER_NAME);
		System.assertEquals('Draft', testOrder.Status, 'The order should to be in status draft');
		Test.setMock(HttpCalloutMock.class, new OrderProductsControllerMock(200));
		OrderProductsController.Response response;
		Test.startTest();
		response = OrderProductsController.activateOrder(testOrder.Id);
		Test.stopTest();
		System.assertEquals('success', response.status, 'A success message is expected');
		System.assertEquals(System.Label.KPN_ORDERS_ACTIVATION_OK, response.message, 'A success message is expected');
		System.assertEquals('Activated', response.orderStatus, 'The status should be activated');
		testOrder = TestUtils.returnOrder(ORDER_NAME);
		System.assertEquals('Activated', testOrder.Status, 'The order should to be in status Activated');
	}
	@IsTest
	static void IfCallToExtSystemDontReturns200SendMessage(){
		Order testOrder = TestUtils.returnOrder(ORDER_NAME);
		System.assertEquals('Draft', testOrder.Status, 'The order should to be in status draft');
		Test.setMock(HttpCalloutMock.class, new OrderProductsControllerMock(400));
		OrderProductsController.Response response;
		Test.startTest();
		response = OrderProductsController.activateOrder(testOrder.Id);
		Test.stopTest();
		System.assertEquals('error', response.status, 'A error message is expected');
		System.assertEquals(System.Label.KPN_ORDERS_CALLOUT_FAILS, response.message, 'A error message is expected');
		System.assertEquals('Draft', response.orderStatus, 'The status should be Draft');
		testOrder = TestUtils.returnOrder(ORDER_NAME);
		System.assertEquals('Draft', testOrder.Status, 'The order should to be in status Draft');
	}
}
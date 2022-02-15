/**
 * @description       : Class for capturing status and messages
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-10-2022   Arunava(Cognizant)   Initial Version
 **/
 
@isTest
public without sharing class AvailableProductsControllerTest {
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
	}
	@isTest
	public static void returnAvailableProductListOrderedByOrderItems(){
		List<PricebookEntry> pbEntries = TestUtils.getPbEntriesByPbName(PRICEBOOK_ENTRY_NAME);
		System.assertEquals(5, pbEntries.size(), 'Just five pbEntries are needed');
		List<OrderItem> orderItems = new List<OrderItem>();
		Map<Id, Integer> checkerMap = new Map<Id, Integer>();
		Order testOrder = TestUtils.returnOrder(ORDER_NAME);
		Integer count = 1;
		for(PricebookEntry pbEntrie : pbEntries){
			OrderItem orderItem= testDataBuilder.aOrderItem()
				.withOrder(testOrder)
				.withQuantity(count)
				.withPriceBook(pbEntrie)
				.withUnitPrice(pbEntrie.UnitPrice)
				.build();
			orderItems.add(orderItem);
			checkerMap.put(pbEntrie.Id, count);
			count += 1;
		}
		insert orderItems;
		List<PricebookEntry> pbListToTable = new List<PricebookEntry>();
		List<PricebookEntry> pbWithSomeQuantity = new List<PricebookEntry>();
		List<PricebookEntry> pbWithoutQuantity = new List<PricebookEntry>();
		Test.startTest();
		List<AvailableProductsController.PBEntrySortable> response = AvailableProductsController.getAvailableProducts(testOrder.Id);
		for(AvailableProductsController.PBEntrySortable pbEntrySortable : response){
			pbListToTable.add(pbEntrySortable.pbEntry);
			if(pbEntrySortable.productQuantityInOrder > 0){
				pbWithSomeQuantity.add(pbEntrySortable.pbEntry);
			}else{
				pbWithoutQuantity.add(pbEntrySortable.pbEntry);
			}
		}
		Test.stopTest();
		System.assertEquals(100, pbListToTable.size(), 'One hundred products are expected');
		System.assertEquals(5, pbWithSomeQuantity.size(), 'Only five products are expected with quantity');
		System.assertEquals(95, pbWithoutQuantity.size(), 'The rest of products are expected without quantity');
		for(Integer i = 0 ; i < pbWithSomeQuantity.size(); i++){
			System.assertEquals(5 - i, checkerMap.get(pbWithSomeQuantity[i].Id), 'The list has to be ordered by Order Items quantity');
			System.assertEquals(pbListToTable[i], pbWithSomeQuantity[i], 'The order of the list has to be the same');
		}
	}
	@IsTest
	public static void IfNoPreviewsOrderItemsCreatedAddSelectProductToOrderItems(){
		Order testOrder = TestUtils.returnOrder(ORDER_NAME);
		List<OrderItem> testOrderItems = [SELECT Id FROM OrderItem WHERE OrderId =: testOrder.Id];
		System.assertEquals(0, testOrderItems.size(), 'The Order should not have Order Items');
		List<PricebookEntry> pbEntries = TestUtils.getPbEntriesByPbName(PRICEBOOK_ENTRY_NAME);
		AuraResponse response;
		Test.startTest();
		response = AvailableProductsController.addProductsToOrder(pbEntries, testOrder.Id);
		Test.stopTest();
		System.assertEquals('success', response.status, 'A success status is expected');
		System.assertEquals(System.Label.KPN_ORDERS_PRODUCTS_ADDED_OK, response.message, 'A success status is expected');
		testOrderItems = [SELECT Id FROM OrderItem WHERE OrderId =: testOrder.Id];
		System.assertEquals(5, testOrderItems.size(), 'A new Order Item should be added to the Order');
	}
	@isTest
	public static void IfExistPreviewsOrderItemsCreatedUpdateOrderItems(){
		Order testOrder = TestUtils.returnOrder(ORDER_NAME);
		List<OrderItem> testOrderItems = [SELECT Id FROM OrderItem WHERE OrderId =: testOrder.Id];
		System.assertEquals(0, testOrderItems.size(), 'The Order should not have Order Items');
		List<PricebookEntry> pbEntries = TestUtils.getPbEntriesByPbName(PRICEBOOK_ENTRY_NAME);
		PricebookEntry refProduct = pbEntries[0];
		OrderItem orderItem = testDataBuilder.aOrderItem()
			.withOrder(testOrder)
			.withQuantity(9)
			.withPriceBook(refProduct)
			.withUnitPrice(refProduct.UnitPrice)
			.build();
		insert orderItem;
		AuraResponse response;
		Test.startTest();
		response = AvailableProductsController.addProductsToOrder(pbEntries, testOrder.Id);
		Test.stopTest();
		System.assertEquals('success', response.status, 'A success status is expected');
		System.assertEquals(System.Label.KPN_ORDERS_PRODUCTS_ADDED_OK, response.message, 'A success status is expected');
		testOrderItems = [SELECT Id, Quantity, PricebookEntryId FROM OrderItem WHERE OrderId =: testOrder.Id];
		System.assertEquals(5, testOrderItems.size(), 'A new Order Item should be added to the Order');
		for(OrderItem updatedOrderItem: testOrderItems){
			if(updatedOrderItem.Id == orderItem.Id){
				System.assertEquals(orderItem.PricebookEntryId , updatedOrderItem.PricebookEntryId, 'The product has to be the same');
				System.assertEquals(10, updatedOrderItem.Quantity, 'The product quantity now is one more');
			}
		}
	}
}

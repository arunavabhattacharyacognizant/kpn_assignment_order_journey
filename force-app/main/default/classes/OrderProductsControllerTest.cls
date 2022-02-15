/**
 * @description       : Test Class for Order Controller
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-15-2022   Arunava(Cognizant)   Initial Version
 **/

@isTest
public without sharing class OrderProductsControllerTest {
    private static final String testPricebookEntry = 'KPN_PB_001';
    private static final String orderName = 'KPN_ORD_001';
    
    @IsTest
	static void getOrderProducts(){
		Order testOrder = TestDataBuilder.getOrder(orderName);
		List<OrderItem> orderItems = new List<OrderItem>();
		Test.startTest();
		orderItems = OrderProductsController.getOrderItems(testOrder.Id);
		Test.stopTest();
		System.assertEquals(5, orderItems.size(), 'Minimum 5 products');
	}

	@IsTest
	static void activateOrder(){
		Order testOrder = TestDataBuilder.getOrder(orderName);
		System.assertEquals('Draft', testOrder.Status, 'The order should to be in status draft');
		Test.startTest();
        LWCResponse response;
		response = OrderProductsController.activateOrder(testOrder.Id);
		Test.stopTest();
		System.assertEquals('success', response.status, 'A success message is expected');
		testOrder = TestDataBuilder.getOrder(orderName);
		System.assertEquals('Activated', testOrder.Status, 'The order should to be in status Activated');
	}
}
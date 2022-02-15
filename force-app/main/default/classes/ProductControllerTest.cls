/**
 * @description       : Test class for test data creation and test product controller
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-15-2022   Arunava(Cognizant)   Initial Version
 **/

@isTest
public without sharing class ProductControllerTest {
    private static final String testPricebookEntry = 'KPN_PB_001';
    private static final String orderName = 'KPN_ORD_001';
    @TestSetup
    static void createTestData() {
        Account acc = TestDataBuilder.anAccount()
            .withName('KPN TEST ACCNT')
            .build();
        insert acc;

        List < Product2 > testProducts = new List < Product2 > ();
        for (Integer i = 0; i < 200; i++) {
            Product2 testProduct = TestDataBuilder.aProduct2()
                .withActive(true)
                .withName('KPN INTERNET v' + i)
                .build();
            testProducts.add(testProduct);
        }
        insert testProducts;
        List < PricebookEntry > standardPriceBookList = new List < PricebookEntry > ();
        for (Product2 product: testProducts) {
            PricebookEntry priceBookEntry = TestDataBuilder.aPricebookEntry()
                .withProduct2(product)
                .withActive(product.IsActive)
                .build();
            standardPriceBookList.add(priceBookEntry);
        }
        insert standardPriceBookList;

        Pricebook2 testOrderPriceBook = TestDataBuilder.aPricebook2()
            .withName(testPricebookEntry)
            .build();
        insert testOrderPriceBook;
        List < PricebookEntry > priceBookList = new List < PricebookEntry > ();
        for (Product2 product: testProducts) {
            PricebookEntry priceBookEntry = TestDataBuilder.aPricebookEntry()
                .withPricebook2(testOrderPriceBook)
                .withProduct2(product)
                .withActive(product.IsActive)
                .withUnitPrice(Integer.valueOf((Math.random() * 10) + 1))
                .build();
            priceBookList.add(priceBookEntry);
        }
        insert priceBookList;
        Order testOrder = TestDataBuilder.aOrder()
            .withAccount(acc)
            .withName(orderName)
            .withPricebook2(testOrderPriceBook)
            .build();
        insert testOrder;

        List < PricebookEntry > pbEntries = TestDataBuilder.getPricebookEntries(testPricebookEntry);
        List < OrderItem > orderItems = new List < OrderItem > ();
        for (PricebookEntry pbEntry: pbEntries) {
            OrderItem orderItem = TestDataBuilder.aOrderItem()
                .withOrder(testOrder)
                .withQuantity(1)
                .withPriceBook(pbEntry)
                .withUnitPrice(pbEntry.UnitPrice)
                .build();
            orderItems.add(orderItem);
        }
        insert orderItems;
    }
}
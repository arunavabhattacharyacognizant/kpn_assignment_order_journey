/**
 * @description       : Class for capturing status and messages
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-10-2022   Arunava(Cognizant)   Initial Version
 **/
 
@isTest
public class TestUtils {
    public static List<PricebookEntry> getPbEntriesByPbName(String pbName){
		return [SELECT Product2.Name, UnitPrice FROM PricebookEntry WHERE Pricebook2.Name =: pbName LIMIT 5];
	}
	public static Order returnOrder(String orderName){
		return [SELECT id, Status FROM Order WHERE Name =: orderName LIMIT 1];
	}
}
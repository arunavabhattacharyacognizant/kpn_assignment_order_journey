/**
 * @description       : Controller class for "Available Products" lwc
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-10-2022   Arunava(Cognizant)   Initial Version
 **/
public with sharing class ProductController {

	public class AvailableProduct implements Comparable {
		@AuraEnabled public PricebookEntry pricebookEntry;
		@AuraEnabled public Integer productQuantityInOrder;
		public AvailableProduct(Integer productQuantityInOrder, PricebookEntry pricebookEntry){
			this.pricebookEntry = pricebookEntry;
			this.productQuantityInOrder = productQuantityInOrder;
		}
		public Integer compareTo(Object compareTo){
			AvailableProduct compareToPricebookEntry = (AvailableProduct)compareTo;
			Integer value = 0;
			if(productQuantityInOrder > compareToPricebookEntry.productQuantityInOrder){
				value = -1;
			}else if(productQuantityInOrder < compareToPricebookEntry.productQuantityInOrder){
				value = 1;
			}else if(productQuantityInOrder == null && compareToPricebookEntry.productQuantityInOrder != null){
				value = 1;
			}else if(productQuantityInOrder != null && compareToPricebookEntry.productQuantityInOrder == null){
				value = -1;
			}
			return value;
		}
	}

    @AuraEnabled(cacheable = true)
    public static List < AvailableProduct > getProducts(Id OrderId) {
        try {
            Order order = [SELECT Pricebook2Id FROM Order WHERE id =: OrderId WITH SECURITY_ENFORCED];
            List < PricebookEntry > pricebookEntries = [SELECT Product2.Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id =: order.Pricebook2Id WITH SECURITY_ENFORCED];
            List < OrderItem > orderItems = getOrderItems(OrderId);
            Map < Id, Integer > pricebookEntryQuantity = new Map < Id, Integer > ();

            for (OrderItem orderItem: orderItems) {
                pricebookEntryQuantity.put(orderItem.PricebookEntryId, Integer.valueOf(orderItem.Quantity));
            }

            List < AvailableProduct > availableProducts = new List < AvailableProduct > ();

            for (PricebookEntry pricebookEntry: pricebookEntries) {
                AvailableProduct availableProduct;
                if (pricebookEntryQuantity.keySet().contains(pricebookEntry.Id)) {
                    availableProduct = new AvailableProduct(pricebookEntryQuantity.get(pricebookEntry.Id), pricebookEntry);
                } else {
                    availableProduct = new AvailableProduct(0, pricebookEntry);
                }
                availableProducts.add(availableProduct);
            }
            availableProducts.sort();
            return availableProducts;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void addToOrder(List < PricebookEntry > pricebookEntries, Id OrderId) {
        try {
            List<OrderItem> newOrderItems = new List<OrderItem>();
			List<OrderItem>	orderItems = getOrderItems(OrderId);
			Map<Id, OrderItem> orderItemsMap = new Map<Id, OrderItem>();
			for(OrderItem orderItem : orderItems){
				orderItemsMap.put(orderItem.PricebookEntryId, orderItem);
			}
			if(pricebookEntries.size() > 0){
				for(PricebookEntry pricebookEntry : pricebookEntries){
					OrderItem orderItem= new OrderItem();
					orderItem.OrderId = OrderId;
					orderItem.PricebookEntryId = pricebookEntry.Id;
					orderItem.UnitPrice = pricebookEntry.UnitPrice;
					orderItem.Quantity = 1;
					if(orderItemsMap.keySet().contains(pricebookEntry.Id)){
						orderItem.Quantity = 1 + orderItemsMap.get(pricebookEntry.Id).Quantity;
						orderItem.Id = orderItemsMap.get(pricebookEntry.Id).Id;
					}
					newOrderItems.add(orderItem);
				}
				Database.upsert(newOrderItems);
			}
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List < OrderItem > getOrderItems(id OrderId) {
        return [SELECT PricebookEntryId, Quantity FROM OrderItem WHERE OrderId =: OrderId WITH SECURITY_ENFORCED];
    }

    
}
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
	  public AvailableProduct(Integer productQuantityInOrder, PricebookEntry pricebookEntry) {
		this.pricebookEntry = pricebookEntry;
		this.productQuantityInOrder = productQuantityInOrder;
	  }
	  public Integer compareTo(Object compareTo) {
		AvailableProduct compareToPricebookEntry = (AvailableProduct) compareTo;
		Integer value = 0;
		if (productQuantityInOrder > compareToPricebookEntry.productQuantityInOrder) {
		  value = -1;
		} else if (productQuantityInOrder < compareToPricebookEntry.productQuantityInOrder) {
		  value = 1;
		} else if (productQuantityInOrder == null && compareToPricebookEntry.productQuantityInOrder != null) {
		  value = 1;
		} else if (productQuantityInOrder != null && compareToPricebookEntry.productQuantityInOrder == null) {
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
	public static LWCResponse addToOrder(List < PricebookEntry > pbList, Id OrderId) {
	  LWCResponse uiResponse = new LWCResponse();
	  try {
		List < OrderItem > orderItemsToUpsert = new List < OrderItem > ();
		List < OrderItem > OrderItems = getOrderItems(OrderId);
		Map < Id, OrderItem > orderItemsBypBEntriesIds = new Map < Id, OrderItem > ();
		for (OrderItem orderItem: OrderItems) {
		  orderItemsBypBEntriesIds.put(orderItem.PricebookEntryId, orderItem);
		}
		if (pbList.size() > 0) {
		  for (PricebookEntry pbEntry: pbList) {
			OrderItem orderItem = new OrderItem();
			orderItem.OrderId = OrderId;
			orderItem.PricebookEntryId = pbEntry.Id;
			orderItem.UnitPrice = pbEntry.UnitPrice;
			orderItem.Quantity = 1;
			if (orderItemsBypBEntriesIds.keySet().contains(pbEntry.Id)) {
			  orderItem.Quantity = 1 + orderItemsBypBEntriesIds.get(pbEntry.Id).Quantity;
			  orderItem.Id = orderItemsBypBEntriesIds.get(pbEntry.Id).Id;
			}
			orderItemsToUpsert.add(orderItem);
		  }
		  Database.upsert(orderItemsToUpsert);
		}
		uiResponse.status = 'success';
		uiResponse.message = System.Label.SUCCESS_PRODUCT_ADDITION;
	  } catch (Exception e) {
		uiResponse.status = 'error';
		uiResponse.message = 'An error has occurred : ' + e.getMessage();
	  }
	  return uiResponse;
	}
  
	private static List < OrderItem > getOrderItems(id OrderId) {
	  return [SELECT PricebookEntryId, Quantity FROM OrderItem WHERE OrderId =: OrderId WITH SECURITY_ENFORCED];
	}
  
  }
/**
 * @description       : Controller for "Order Products" lwc
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-13-2022   Arunava(Cognizant)   Initial Version
 **/
public with sharing class OrderProductsController {

  /** This method to submit the order to the request catcher API*/
  @AuraEnabled
  public static Integer submitOrder(Order order, List < OrderItem > orderItems) {
      try {
          JSONGenerator submitOrderJson = JSON.createGenerator(true);
          submitOrderJson.writeStartObject();
          submitOrderJson.writeStringField('accountNumber', order.Account.AccountNumber);
          submitOrderJson.writeStringField('orderNumber', order.OrderNumber);  
          submitOrderJson.writeStringField('type', order.Type);      
          submitOrderJson.writeStringField('status', order.Status);
          submitOrderJson.writeFieldName('orderProducts');
          submitOrderJson.writeStartArray();
          for (OrderItem orderItem: orderItems) {
              submitOrderJson.writeStartObject();
              submitOrderJson.writeStringField('name', orderItem.Product2.Name);
              submitOrderJson.writeStringField('code', orderItem.Product2.ProductCode);
              submitOrderJson.writeNumberField('unitPrice', orderItem.UnitPrice);
              submitOrderJson.writeNumberField('quantity', Integer.valueOf(orderItem.Quantity));          
              submitOrderJson.writeEndObject();
          }
          submitOrderJson.writeEndArray();
          submitOrderJson.writeEndObject();
          String submitOrderRequestBody = submitOrderJson.getAsString();
          HttpRequest submitOrderRequest = new HttpRequest();
          submitOrderRequest.setEndpoint('https://submitorder.requestcatcher.com/test');
          submitOrderRequest.setMethod('POST');
          submitOrderRequest.setBody(submitOrderRequestBody);
          Http http = new Http();
          HTTPResponse submitOrderResponse = http.send(submitOrderRequest);
          return submitOrderResponse.getstatusCode();
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
  }

  /** This method is to call submit order and update order status once its successfully placed the order to request catcher */
  @AuraEnabled
  public static LWCResponse activateOrder(Id OrderId) {
      LWCResponse uiResponse = new LWCResponse();
      try {
          Order order = [SELECT Status, Account.AccountNumber, OrderNumber, Type, TotalAmount FROM Order WHERE Id =: OrderId WITH SECURITY_ENFORCED];
          List < OrderItem > orderItems = [SELECT Product2.Name, Product2.ProductCode, Quantity, UnitPrice, TotalPrice, OrderItemNumber FROM OrderItem WHERE OrderId =: OrderId WITH SECURITY_ENFORCED];
          Integer submitOrderResponseCode = submitOrder(order, orderItems);
          if (submitOrderResponseCode == 200) {
              order.Status = 'Activated';
              update order;
              for (OrderItem orderItem: orderItems) {
                  orderItem.Status__c = 'Activated';
              }
              update orderItems;
              uiResponse.status = 'success';
              uiResponse.message = System.Label.SUCCESS_SUBMIT_ORDER;
          } else {
              uiResponse.status = 'error';
              uiResponse.message = System.Label.ERROR_SUBMIT_ORDER;
          }
      } catch (Exception e) {
          uiResponse.status = 'error';
          uiResponse.message = 'An error has occurred : ' + e.getMessage();
      }
      return uiResponse;
  }

  /** This method is to get all the order items */
  @AuraEnabled
  public static List < OrderItem > getOrderItems(Id OrderId) {
      try {
          return [SELECT Product2.Name, Quantity, UnitPrice, TotalPrice FROM OrderItem WHERE OrderId =: OrderId WITH SECURITY_ENFORCED];
      } catch (Exception e) {
          throw new AuraHandledException(e.getMessage());
      }
  }
}

/**
 * @description       : Class for capturing status and messages response
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-10-2022   Arunava(Cognizant)   Initial Version
 **/
 
@isTest
public class OrderProductsControllerMock implements HttpCalloutMock {
	public Integer statusCode;
	public OrderProductsControllerMock(Integer statusCode) {
		this.statusCode = statusCode;
	}
	public HTTPResponse respond(HTTPRequest req) {
		System.assert(req != null, 'No request found');
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"example":"test"}');
		res.setStatusCode(statusCode);
		return res;
	}
}
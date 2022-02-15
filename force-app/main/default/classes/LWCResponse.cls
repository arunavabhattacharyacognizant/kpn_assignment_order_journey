/**
 * @description       : To capture request status and messages response in UI
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-10-2022   Arunava(Cognizant)   Initial Version
 **/

public virtual class LWCResponse {
    @AuraEnabled
    public String status {
        get;
        set;
    }
    @AuraEnabled
    public String message {
        get;
        set;
    }
}
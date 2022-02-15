/**
 * @description       : js controller for "Available Products" lwc
 * @author            : Arunava(Cognizant)
 * 
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   02-14-2022   Arunava(Cognizant)   Initial Version
 **/

 import { LightningElement, api, wire, track } from 'lwc';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import ERROR_PRODUCT_ADDITION_MIN_REQ from '@salesforce/label/c.ERROR_PRODUCT_ADDITION_MIN_REQ';
 import getProducts from '@salesforce/apex/ProductController.getProducts';
 import addToOrder from '@salesforce/apex/ProductController.addToOrder';
 import { getRecord } from 'lightning/uiRecordApi';
 import { publish, MessageContext } from 'lightning/messageService';
 import orderItemsAddedEvent from '@salesforce/messageChannel/orderItemsAddedEvent__c';
 
 const columns = [
	{
		label: 'Name',
		fieldName: 'Link',
		typeAttributes: {
			label: {
				fieldName: 'Name'
			},
			target: '_blank'
		},
		type: 'url',
		hideDefaultActions : 'true',
		sortable: true
	},
	{ label: 'List Price', fieldName: 'UnitPrice', sortable: true, type: 'currency', hideDefaultActions : 'true',
		cellAttributes: {
			alignment: 'left'
		}
	}
];
export default class AvailableProductsController extends LightningElement {
	/** Custom Labels */
		labels = {
			ERROR_PRODUCT_ADDITION_MIN_REQ
		}
	/** View controller attributes */
		orderStatus = 'Draft';
		areDetailsVisible = false;
		hideCheckboxColums = false;
	/** dataTable controller attributes */
		columns = columns;
		dataTable = [];
		initialOffset = 10
		initialData = [];
		defaultSortDirection = 'asc';
		sortDirection = 'asc';
		sortedBy;
		selectedRows = [];
	/** -- */
		@api recordId;
	/** to send the product added method */
		@wire(MessageContext) messageContext;
	/** to get the status of the order and control availability to add products */
		@wire(getRecord, {recordId : '$recordId', fields: ['Order.Status']})
		getRecordCallBack({error, data}){
			if(data){
				this.orderStatus = data.fields.Status.value
				this.hideCheckboxColums = this.orderStatus === 'Activated';
			}else if(error){
				console.log(error);
			}
		}
	/** to get the product entries associated to the order */
		@wire(getProducts, {OrderId : '$recordId'})
		wiredProject({error, data}){
			if (data) {
				if(data.length > 0){
					data.forEach((sortedData, idx) => {
						let dataToTable = {};
						dataToTable.Id = sortedData.pricebookEntry.Id;
						dataToTable.Name = sortedData.pricebookEntry.Product2.Name;
						dataToTable.UnitPrice = sortedData.pricebookEntry.UnitPrice;
						dataToTable.Link = '/' + sortedData.pricebookEntry.Id;
						this.dataTable.push(dataToTable);
						if(idx < this.initialOffset){
							this.initialData.push(dataToTable);
						}
					});
				}
			}else if(error){
				console.log(error);
			}
			if(this.dataTable.length > 0){
				this.areDetailsVisible = true;
			}
		}
	/** to control datatable behavior */
		sortBy(field, reverse) {
			return function(dataA, dataB) {
				field = field == 'Link' ? 'Name' : field;
				let detailA = dataA[field];
				let detailB = dataB[field];
				if(detailA == detailB){
					return 0;
				}else {
					return (detailA > detailB ? 1 : -1) * reverse;
				}
			};
		}
		sortTable(event) {
			const { fieldName: sortedBy, sortDirection } = event.detail;
			const cloneData = [...this.initialData];
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
			this.initialData = cloneData;
			this.sortDirection = sortDirection;
			this.sortedBy = sortedBy;
		}
		loadMoreProducts(){
			let totalElements = this.dataTable.length;
			let offSet = this.initialOffset;
			let currentVisibleElements = this.initialData.length;
			if(totalElements === currentVisibleElements){
				return;
			}
			if(totalElements < offSet){
				this.initialData = this.dataTable;
				return;
			}else{
				let nextOffSet = currentVisibleElements + offSet;
				if(totalElements < nextOffSet){
					this.initialData = this.dataTable;
				}else{
					this.initialData = this.initialData.concat(this.dataTable.slice(currentVisibleElements, nextOffSet));
				}
			}
		}
		defineSelectedProducts(event){
			this.selectedRows = event.detail.selectedRows;
		}
	/** method to invoke Apex update method */
		addProducts(){
			let OrderId = this.recordId;
			let selectedProducts = this.selectedRows;
			let pbList = [];
			if(selectedProducts.length == 0){
				this.sendMessageToUser('warning', this.labels.ERROR_PRODUCT_ADDITION_MIN_REQ);
			}else{
				selectedProducts.forEach(selectedProduct => {
					let pbEntryToAdd = { 'sobjectType': 'PricebookEntry' };
					pbEntryToAdd.Id = selectedProduct.Id;
					pbEntryToAdd.UnitPrice = selectedProduct.UnitPrice;
					pbList.push(pbEntryToAdd);
				});
				addToOrder({pbList: pbList, OrderId: OrderId})
					.then(result => {
						this.sendMessageToUser(result.status, result.message);
						publish(this.messageContext, orderItemsAddedEvent);
					}).catch(error => {
						console.log(error);
						this.sendMessageToUser(error.status, error.message);
					});
			}
		}
		sendMessageToUser(status, message){
			const evt = new ShowToastEvent({
				message: message,
				variant: status,
			});
			this.dispatchEvent(evt);
		}
}
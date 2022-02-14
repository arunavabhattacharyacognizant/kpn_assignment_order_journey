import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import KPN_ORDERS_ACTIVATION_ERROR from '@salesforce/label/c.KPN_ORDERS_ACTIVATION_ERROR';
import getOrderItems from '@salesforce/apex/OrderProductsController.getOrderItems';
import activateOrder from '@salesforce/apex/OrderProductsController.activateOrder';
/** To listen the event orderItemsAddedEvent from the availableProducts component */
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import {
    subscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
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
	{ label: 'List Price', fieldName: 'UnitPrice', sortable: true, type: 'currency', hideDefaultActions : 'true' },
	{ label: 'Quantity ', fieldName: 'Quantity', sortable: true, type: 'number', hideDefaultActions : 'true' },
	{ label: 'Total Price', fieldName: 'TotalPrice', sortable: true, type: 'currency', hideDefaultActions : 'true' }
];
export default class OrderProducts extends LightningElement {
	/** Custom Labels */
		labels = {
			KPN_ORDERS_ACTIVATION_ERROR
		}
	/** View controller attributes */
		orderStatus = 'Draft';
		activatingOrder = false;
		areDetailsVisible = false;
	/** dataTable controller attributes */
		columns = columns;
		dataTable = [];
		initialOffset = 10
		initialData = [];
		defaultSortDirection = 'asc';
		sortDirection = 'asc';
		sortedBy;
	/** -- */
		@api recordId;
	/** to get the status of the order and control activation button availability */
		@wire(getRecord, {recordId : '$recordId', fields: ['Order.Status']})
		getRecordCallBack({error, data}){
			if(data){
				this.orderStatus = data.fields.Status.value
				this.activatingOrder = this.orderStatus === 'Activated';
			}else if(error){
				console.log(error);
			}
		}
	/** to listen the event */
		subscription = null;
		@wire(MessageContext) messageContext;
	/**
	 * Because the @wire decoration doesn't work to update the table when the event is
	 * listen, the option is to invoke the apex method to get the data imperatively.
	 */
		connectedCallback() {
			this.subscribeToMessageChannel();
			this.getOrderItemsMethod();
		}
	/** wrapper method of the apex invocation */
		getOrderItemsMethod(){
			let dataTable = [];
			let initialData = [];
			getOrderItems({OrderId : this.recordId})
				.then(result => {
					if(result.length > 0){
						result.forEach((orderItem, idx) => {
							let dataToTable = {};
							dataToTable.Id = orderItem.Id;
							dataToTable.Name = orderItem.Product2.Name;
							dataToTable.UnitPrice = orderItem.UnitPrice;
							dataToTable.Link = '/' + orderItem.Id;
							dataToTable.Quantity = orderItem.Quantity;
							dataToTable.TotalPrice = orderItem.TotalPrice;
							dataTable.push(dataToTable);
							if(idx < this.initialOffset){
								initialData.push(dataToTable);
							}
							console.log(dataToTable);
						});
					}
					this.dataTable = dataTable;
					this.initialData = initialData;
					this.areDetailsVisible = true;
				}).catch(error => {
					console.log(error);
					this.sendMessageToUser('error', 'Error loading');
					this.areDetailsVisible = true;
				});
		}
		activateOrder() {
			this.activatingOrder = true;
			let OrderId = this.recordId;
			activateOrder({OrderId: OrderId})
					.then(result => {
						this.sendMessageToUser(result.status, result.message);
						getRecordNotifyChange([{recordId: OrderId}]);
						if(result.orderStatus != 'Activated'){
							this.activatingOrder = false;
						}
					}).catch(error => {
						console.log(error);
						this.sendMessageToUser('error', this.labels.KPN_ORDERS_ACTIVATION_ERROR);
						this.activatingOrder = false;
					});
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
	/** to listen and handle the order added event */
		subscribeToMessageChannel() {
			if (!this.subscription) {
				this.subscription = subscribe(
					this.messageContext,
					orderItemsAddedEvent,
					(message) => this.handleMessage(),
					{ scope: APPLICATION_SCOPE }
				);
			}
		}
		handleMessage() {
			this.activatingOrder = true;
			this.areDetailsVisible = false;
			this.getOrderItemsMethod();
			this.activatingOrder = false;
			this.areDetailsVisible = true;
		}
		sendMessageToUser(status, message){
			const evt = new ShowToastEvent({
				message: message,
				variant: status,
			});
			this.dispatchEvent(evt);
		}
}
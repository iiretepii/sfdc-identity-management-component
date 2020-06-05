({
    onLoad: function(component, event) {
        console.log('onLoad call');
        //call apex class method
        var action = component.get('c.fetchWrapperSessions');
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Identity Management Component: response from controller - ' + JSON.stringify(response.getReturnValue()));
                //set response value in ListOfContact attribute on component.
                component.set('v.ListOfSessions', response.getReturnValue());
                // set deafult count and select all checkbox value to false on load 
                component.set("v.selectedCount", 0);
                component.find("box3").set("v.value", false);
            } else {
                console.log('Identity Management Component: Error - ' + JSON.stringify(response));
            }
        });
        $A.enqueueAction(action);
    },

    deleteSelectedHelper: function(component, event, recordIds) {
        //call apex class method
        var action = component.get('c.deleteRecords');
        // pass the all selected record's Id's to apex method 
        action.setParams({
            "recordIds": recordIds
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(state);
                if (response.getReturnValue() != '') {
                    // if getting any error while delete the records , then display a alert msg/
                    alert('The following error has occurred. while Delete record-->' + response.getReturnValue());
                } else {
                    console.log('check it--> delete successful');
                }
                // call the onLoad function for refresh the List view    
                this.onLoad(component, event);
            }
        });
        $A.enqueueAction(action);
    },
})
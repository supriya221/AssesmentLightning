import { LightningElement,track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import GOOGLE_MAPS from '@salesforce/resourceUrl/googleAddress';
import getDirections from '@salesforce/apex/AddressSearch.getDirections';

export default class AddAssessment extends LightningElement {
    @track originAddress;
    @track destinationAddress;
    @track transportationModes = [
        { label: 'Driving', value: 'driving' },
        { label: 'Flying', value: 'flying' },
    ];
    @track selectedTransportationMode = 'driving';

    connectedCallback() {
        Promise.all([
            loadScript(this, GOOGLE_MAPS)
        ])
        .then(() => {
            this.initAutocomplete();
        })
        .catch((error) => {
            console.error(error);
        });
    }

    initAutocomplete() {
        const originInput = this.template.querySelector('#originAddress');
        const destinationInput = this.template.querySelector('#destinationAddress');

        const originAutocomplete = new google.maps.places.Autocomplete(originInput);
        originAutocomplete.addListener('place_changed', () => {
            this.originAddress = originAutocomplete.getPlace().formatted_address;
        });

        const destinationAutocomplete = new google.maps.places.Autocomplete(destinationInput);
        destinationAutocomplete.addListener('place_changed', () => {
            this.destinationAddress = destinationAutocomplete.getPlace().formatted_address;
        });
    }

    handleOriginChange(event) {
        this.originAddress = event.target.value;
    }

    handleDestinationChange(event) {
        this.destinationAddress = event.target.value;
    }

    handleTransportationModeChange(event) {
        this.selectedTransportationMode = event.target.value;
    }

    handleClick(){
        getDirections({originAddress: this.originAddress,destinationAddress: this.destinationAddress})
        .then(result => {
                this.distanceAndTime = result;
            })
            .catch(error => {
                console.error(error);
            });
        }
        
    }

public class AddressSearch {
      
            public class DistanceAndTime {
                @AuraEnabled public String distanceText;
                @AuraEnabled public Double distanceValue;
                @AuraEnabled public String durationText;
                @AuraEnabled public Double durationValue;
                @AuraEnabled public Double cost;
            }
            
            @AuraEnabled
            public static DistanceAndTime getDirections(String originAddress, String destinationAddress,String transportationMode) {
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String apiKey = 'AIzaSyDxqIbP0ep00kz_qaQGt_Xgt38EMXD7dLs';
                request.setEndpoint('https://maps.googleapis.com/maps/api/distancematrix/json?origins=' + EncodingUtil.urlEncode(originAddress, 'UTF-8') + '&destinations=' + EncodingUtil.urlEncode(destinationAddress, 'UTF-8') + '&mode=' + transportationMode + '&key=' + apiKey);
                request.setMethod('GET');
                HttpResponse response = http.send(request);
                
                DistanceAndTime result = new DistanceAndTime();
                
                if (response.getStatusCode() == 200) {
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    List<Object> rows = (List<Object>) responseMap.get('rows');
                    Map<String, Object> elements = (Map<String, Object>) rows.get(0);
                    List<Object> distanceElement = (List<Object>) elements.get('elements');
                    Map<String, Object> distance = (Map<String, Object>)((Map<String, Object>)distanceElement[0]).get('distance');
                    result.distanceText = (String) distance.get('text');
                    result.distanceValue = (Double) distance.get('value');
                    Map<String, Object> duration = (Map<String, Object>)((Map<String, Object>)distanceElement[0]).get('duration');
                    result.durationText = (String) duration.get('text');
                    result.durationValue = (Double) duration.get('value');
                    
                    List<Transporatation_Rate__mdt> rates = [SELECT DeveloperName, Rate_Per_Mile__c FROM Transporatation_Rate__mdt];
                    Map<String, Double> rateMap = new Map<String, Double>();
                    for (Transporatation_Rate__mdt rate : rates) {
                        rateMap.put(rate.DeveloperName, rate.Rate_Per_Mile__c);
                    }
                    
                    Double ratePerMile = rateMap.get(transportationMode);
                    result.cost = (result.distanceValue / 1609.34) * ratePerMile; // Convert distance from meters to miles
                }
                
                return result;
            }
            
        }
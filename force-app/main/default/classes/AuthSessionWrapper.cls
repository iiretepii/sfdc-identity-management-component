public class AuthSessionWrapper {
    @AuraEnabled
    public AuthSession authSesh {get;set;}
    @AuraEnabled
    public Boolean isCurrent {get;set;}
    @AuraEnabled
    public UserDevice ud {get;set;}

    public AuthSessionWrapper(AuthSession authSesh) {
        this.authSesh = authSesh;
        this.isCurrent = false;
    }
}
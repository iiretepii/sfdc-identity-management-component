public without sharing class IdentityManagementController {

    @AuraEnabled
    public static List<AuthSessionWrapper> fetchWrapperSessions() {
        Map<Id,AuthSessionWrapper> authSessionWrappers = new Map<Id,AuthSessionWrapper>();
        Map<Id,AuthSessionWrapper> loginHistoryToAuthSession = new Map<Id,AuthSessionWrapper>();
        List<AuthSession> authSessions = [
            SELECT 	Id, CreatedDate, IsCurrent, LastModifiedDate,
                    LoginHistoryId, LoginHistory.Platform, LoginHistory.Browser,
                    // LoginGeo.City, LoginGeo.Country, LoginGeoId,
                    LoginType, LogoutUrl, NumSecondsValid, ParentId, SessionSecurityLevel,
                    SessionType, SourceIp, UserType, UsersId
            FROM 	AuthSession 
            WHERE 	UsersId=:UserInfo.getUserId()
            ORDER BY ParentID NULLS FIRST, CreatedDate
        ];

        for(AuthSession authSesh:authSessions) {
            if(authSesh.ParentId == null) {
                AuthSessionWrapper asw = new AuthSessionWrapper(authSesh);
                authSessionWrappers.put(authSesh.Id,asw);
                if(authSesh.isCurrent) {
                    authSessionWrappers.get(authSesh.Id).isCurrent = true;
                }
                loginHistoryToAuthSession.put(authSesh.LoginHistoryId, asw);
            } else {
                if(authSesh.isCurrent && authSessionWrappers.containsKey(authSesh.ParentId)) {
                    authSessionWrappers.get(authSesh.ParentId).isCurrent = true;
                }
            }
        }

        for(UserDevice ud:[
            SELECT 	BrowserType, DeviceNativeUid, DeviceType, IsVerified, LastLoginHistoryId, Name, PlatformType, PlatformVersion,
                    Status, UserId, UserLastSeen
            FROM 	UserDevice
            WHERE 	LastLoginHistoryId IN:loginHistoryToAuthSession.keySet()
        ]) {
            loginHistoryToAuthSession.get(ud.LastLoginHistoryId).ud = ud;
        }

        return authSessionWrappers.values();
    }

    @AuraEnabled
    public static List<String> deleteRecords(List<String> recordIds) {

        // for store Error Messages  
        List<String> oErrorMsg = new List<String>();

        // Query Records for delete where id in recordIds
        List<AuthSession> selectedRecords = [
            SELECT 	Id 
            FROM 	AuthSession 
            WHERE 	Id IN:recordIds
        ];

        Database.DeleteResult[] results = Database.delete(selectedRecords, false);

        for (Database.DeleteResult dr: results) {
            if (dr.isSuccess()) {
                system.debug('successful deleted record(s)');
            } else {
                oErrorMsg.add('');
                for (Database.Error err: dr.getErrors()) {
                    oErrorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
        return oErrorMsg;
    }
}
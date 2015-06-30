%set user home
import java.lang.*;

USER_HOME=cast(System.getProperty('user.home'),'char');

javaaddpath(fullfile(USER_HOME,'.m2','repository','edu','berkeley','path',...
    'CORE','0.1-SNAPSHOT','CORE-0.1-SNAPSHOT.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','edu','berkeley','path',...
    'matlab','0.1-SNAPSHOT','matlab-0.1-SNAPSHOT.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','edu','berkeley','path',...
    'NETCONFIG','0.1-SNAPSHOT','NETCONFIG-0.1-SNAPSHOT.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','edu','berkeley','path',...
    'pemsviz','0.1-SNAPSHOT','pemsviz-0.1-SNAPSHOT.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','org','postgis',...
    'postgis-jdbc','1.3.3','postgis-jdbc-1.3.3.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','oracle',...
    'ojdbc6','11.2.0.1.0','ojdbc6-11.2.0.1.0.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','oracle',...
    'sdoapi','11.2.0.3.0','sdoapi-11.2.0.3.0.jar'));
 
javaaddpath(fullfile(USER_HOME,'.m2','repository','oracle',...
    'sdoutl','11.2.0.3.0','sdoutl-11.2.0.3.0.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','postgresql',...
'postgresql','9.1-901-1.jdbc4','postgresql-9.1-901-1.jdbc4.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','org','apache',...
    'commons','commons-math','2.2','commons-math-2.2.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','edu','berkeley','path',...
    'readldt','0.1-SNAPSHOT','readldt-0.1-SNAPSHOT.jar'));

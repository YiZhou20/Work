%set user home
import java.lang.*;

USER_HOME=cast(System.getProperty('user.home'),'char');

javaaddpath(fullfile(USER_HOME,'.m2','repository','edu','berkeley','path',...
    'CORE','0.1-SNAPSHOT','CORE-0.1-SNAPSHOT.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','edu','berkeley','path',...
    'readldt','0.1-SNAPSHOT','readldt-0.1-SNAPSHOT.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','oracle',...
    'ojdbc6','11.2.0.1.0','ojdbc6-11.2.0.1.0.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','oracle',...
    'sdoapi','11.2.0.3.0','sdoapi-11.2.0.3.0.jar'));
 
javaaddpath(fullfile(USER_HOME,'.m2','repository','oracle',...
    'sdoutl','11.2.0.3.0','sdoutl-11.2.0.3.0.jar'));

javaaddpath(fullfile(USER_HOME,'.m2','repository','org','apache',...
    'commons','commons-math','2.2','commons-math-2.2.jar'));

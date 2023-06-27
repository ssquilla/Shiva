using Secret;
using service;

namespace session{

    public struct LoginFields {
        string loginField;
        string passField;
    }

    public struct ConnectingValues {
        string login;
        string password;
    }

    
    public class LoginManager : GLib.Object{

        private string echapChar;

        private Secret.Schema secretSchema;

        private string networkName;

        construct {
            createPassSchema();
            echapChar = "\\";
        }

        public LoginManager(PersistentWebView persistentWebView){
            networkName = persistentWebView.networkName;
        }

        public void createPassSchema(){
            secretSchema = new Secret.Schema ("org.shiva.Password", Secret.SchemaFlags.DONT_MATCH_NAME,
            "network", Secret.SchemaAttributeType.STRING);
        }	

        public void updateLogins(string login, string password){  
            assert(login.length>0 && password.length>0);
            removeLogins();
            createLogins(login,password);
        }

        public void updateLoginsIfDifferent(string login, string password){
            var logins = lookupLogins();
            if (logins==null){
                updateLogins(login,password);
            } else {
                if(login.length>0 && password.length>0){
                    var oldLogin = logins.login;
                    var oldPass = logins.password;
                    if(oldLogin!=login || oldPass!=password){
                        stdout.printf("Updating logins.\n");
                        updateLogins(login,password);
                    }
                }
            }
        }

        public void createLogins(string login, string password){
                var attributes = createPassHashTable();
                string label = networkName+".logins";
                var toStore = assembleLogins(login,password);
                Secret.password_storev.begin (secretSchema, attributes, Secret.COLLECTION_DEFAULT,
                    label, toStore, null, (obj, async_res) => {
                    try{
                        bool res = Secret.password_store.end (async_res);
                        if (res){
                            stdout.printf("Password for %s - network %s stored.\n",login,networkName);
                        } else {
                            stderr.printf("Can't store password %s - network %s.\n",login,networkName);
                        }
                    } catch(GLib.Error e){
                        stderr.printf("Can't store password %s - network %s.\n %s\n",login,networkName,e.message);
                    }
                });     
        }

        public string assembleLogins(string login,string password){
            assert(login.length>0 && password.length>0);
            assert(!login.contains(echapChar));
            assert(!password.contains(echapChar));
            return encrypt(login+echapChar+password);
        }

        public ConnectingValues? extractLogins(string assembledLogins){
            string decrypted = decrypt(assembledLogins);
            var splitted = decrypted.split(echapChar);
            assert(splitted.length == 2);
            ConnectingValues logins = ConnectingValues();
            logins.login = decrypt(splitted[0]);
            logins.password = decrypt(splitted[1]);
            return logins;
        }

        public void removeLogins() {
            var attributes = createPassHashTable();
            Secret.password_clearv.begin (secretSchema, attributes, null, (obj, async_res) => {
                try{
                    bool removed = Secret.password_clearv.end (async_res);
                    if (!removed){
                        stdout.printf("No password to remove.\n");
                    }
                } catch (GLib.Error e){
                    stderr.printf("network %s: %s",networkName,e.message);
                }
 
            });
        }

        /* consulter le mot de passe de manière SYNCHRONE */
        public ConnectingValues? lookupLogins(){
            //var attributes = createPassHashTable(network);
            try{
                string encryptedLogins = Secret.password_lookup_sync (secretSchema, null,"network",networkName);
                if (encryptedLogins != null){
                    return extractLogins(encryptedLogins);
                } else {
                    return null;
                }
            } catch (GLib.Error e){
                stderr.printf("%s : maybe no password to lookup. %s\n",networkName,e.message);
                return null;
            }

        }

        public GLib.HashTable<string,string> createPassHashTable(){
            var attributes = new GLib.HashTable<string,string> (str_hash, str_equal);
            attributes["network"] = networkName;
            return attributes;
        }

        public string encrypt(string log_value){
            return log_value;
        }

        public string decrypt(string encrypted_log){
            return encrypted_log;
        }
    }

}
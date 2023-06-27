
using WebKit;
using GLib;
using session;

namespace service{
    public struct WebViewDescription {
        string networkName;
        string URL;
        session.LoginFields? loginFields;
        session.PageBlocks? pageBlocks;
        session.DeleteElements? deleteElements;

        public WebViewDescription(string networkName, string URL,LoginFields? loginFields, PageBlocks? pageBlocks, DeleteElements? deleteElements){
            this.networkName = networkName;
            this.URL = URL;
            this.loginFields = loginFields;
            this.pageBlocks = pageBLocks;
            this.deleteElements = deleteElements;
        }
    }

    public class PersistentWebView : WebKit.WebView  {
        
        public string defaultURL { get; set;}

        public string networkName { get ; set;}

        public Secret.Schema secretSchema {get; set;}

        public LoginFields? loginFields { get; set;}

        private session.PageAutomatizer pageAutomatizer {get; set;}

        public WebViewDescription description;

        construct{
            loginFields = null;
            //settings.allow_modal_dialogs = true;
        }

        public bool needLogins(){
            return (loginFields!=null);
        }

        public void setWindow(GUI.Window mainWindow){
            pageAutomatizer.setWindow(mainWindow);
        }

        public PersistentWebView(service.WebViewDescription description,LoginFields? loginFields){
            Object();
            this.defaultURL = description.URL;
            this.networkName = description.networkName;
            this.loginFields = loginFields;
            this.description = description;
            
            assert(description.pageBlocks == null || (description.pageBlocks.attributes.length == description.pageBlocks.values.length) );
            setupWebView();
            //permissionRequest = new NotificationPermissionRequest();
            //new WebKit.NotificationPermissionRequest().allow();
            pageAutomatizer = new PageAutomatizer(this);

        }

        public void clearLogins(){
            if (needLogins()){
                pageAutomatizer.clearLogins();
            }
        }
        
        public void setupWebView(){
            load_uri(defaultURL);
            // connect signals
        }

        public void tryShiftBlock(){
            stdout.printf(networkName+" shifting blocks ...\n");
            pageAutomatizer.shiftBlock();
        }
        
        public void addToStack(Gtk.Stack stack){
            var title = networkName + " : homepage";
            var name = networkName;
            stack.add_titled(this,title,name);
        }
        
        public void reloadURL(){
            load_uri(defaultURL);
        }
    }
}
